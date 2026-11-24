import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/config/app_config.dart';
import '../../app/router/route_names.dart';
import '../../firebase_options_employer.dart' as employer_firebase;
import '../../firebase_options_worker.dart' as worker_firebase;
import '../config/firebase_config.dart';

FirebaseOptions _firebaseOptionsFor(AppConfig config) => config.isWorker
    ? worker_firebase.DefaultFirebaseOptions.currentPlatform
    : employer_firebase.DefaultFirebaseOptions.currentPlatform;

const AndroidNotificationChannel _notificationChannel = AndroidNotificationChannel(
  'patchbro_high_importance',
  'Patch Bro Notifications',
  description: 'Notifications about jobs, invitations and updates.',
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      final config = AppConfig.fromEnvironment();

      await Firebase.initializeApp(options: FirebaseConfig.optionsFor(config));
    }

    debugPrint(
      'PUSH: background message received '
      '(${message.messageId ?? 'no id'}).',
    );
  } catch (error, stackTrace) {
    debugPrint('PUSH: background handler failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class AppPushNotificationService {
  AppPushNotificationService(this._supabase, this._config);

  final SupabaseClient _supabase;
  final AppConfig _config;

  bool _initialized = false;

  String? _registeredUserId;
  String? _token;

  GoRouter? _router;
  RemoteMessage? _pendingTap;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  // ---------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized || kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    try {
      // 1. Initialize Firebase.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: _firebaseOptionsFor(_config));
      }

      debugPrint('PUSH: Firebase ready for ${_config.flavor}.');

      // 2. Initialize local notifications separately.
      // A local notification icon/resource error must not
      // prevent Firebase Messaging from initializing.

      await _initializeLocalNotifications();

      // 3. Request notification permission.
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.getNotificationSettings();

      var authorization = settings.authorizationStatus;

      if (authorization == AuthorizationStatus.notDetermined) {
        authorization = (await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        )).authorizationStatus;
      }

      debugPrint('PUSH: notification permission is $authorization.');

      if (authorization == AuthorizationStatus.denied) {
        debugPrint(
          'PUSH: permission denied; '
          'user can enable it in system settings.',
        );
      }

      // 4. iOS foreground notification presentation.
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // 5. Listen for foreground messages.
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError: (Object error) {
          debugPrint('PUSH: foreground stream failed: $error');
        },
      );

      // 6. Listen for notification taps.
      _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handleTap(message),
        onError: (Object error) {
          debugPrint('PUSH: tap stream failed: $error');
        },
      );

      // 7. Listen for FCM token refresh.
      // ignore: deprecated_member_use
      _tokenRefreshSubscription = messaging.onTokenRefresh.listen(
        _handleTokenRefresh,
        onError: (Object error) {
          debugPrint('PUSH: token refresh stream failed: $error');
        },
      );

      // 8. Listen for Supabase authentication changes.
      _authSubscription = _supabase.auth.onAuthStateChange.listen(
        _handleAuthState,
        onError: (Object error) {
          debugPrint('PUSH: auth stream failed: $error');
        },
      );

      _initialized = true;

      debugPrint('PUSH: Firebase Messaging listeners initialized.');

      // 9. Handle notification that opened the terminated app.
      final initialMessage = await messaging.getInitialMessage();

      if (initialMessage != null) {
        _handleTap(initialMessage);
      }

      // 10. Register FCM token for current user.
      await registerForCurrentUser();
    } catch (error, stackTrace) {
      debugPrint('PUSH: initialization failed: $error');

      debugPrintStack(stackTrace: stackTrace);

      await _cancelSubscriptions();

      _initialized = false;

      rethrow;
    }
  }

  // ---------------------------------------------------------
  // LOCAL NOTIFICATION INITIALIZATION
  // ---------------------------------------------------------

  Future<void> _initializeLocalNotifications() async {
    try {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('PUSH: local notification tapped.');

          final data = _decodePayload(response.payload);

          if (data != null) {
            _handleTapData(data);
          }
        },
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(_notificationChannel);

      debugPrint('PUSH: local notifications and Android channel ready.');
    } catch (error, stackTrace) {
      debugPrint('PUSH: local notification initialization failed: $error');

      debugPrintStack(stackTrace: stackTrace);

      // Continue Firebase Messaging initialization.
    }
  }

  // ---------------------------------------------------------
  // ROUTER
  // ---------------------------------------------------------

  void attachRouter(GoRouter router) {
    _router = router;

    final pending = _pendingTap;

    _pendingTap = null;

    if (pending != null) {
      _navigateForMessage(pending);
    }
  }

  // ---------------------------------------------------------
  // FOREGROUND NOTIFICATIONS
  // ---------------------------------------------------------

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'PUSH: foreground message received '
      '(${message.messageId ?? 'no id'}).',
    );

    if (!Platform.isAndroid) return;

    final title = message.notification?.title ?? message.data['title']?.toString();

    final body =
        message.notification?.body ??
        message.data['message']?.toString() ??
        message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      debugPrint('PUSH: foreground message has no display title or body.');

      return;
    }

    try {
      final id =
          (message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch) & 0x7fffffff;

      await _localNotifications.show(
        id: id,
        title: title ?? 'Patch Bro',
        body: body ?? 'You have a new notification.',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _notificationChannel.id,
            _notificationChannel.name,
            channelDescription: _notificationChannel.description,
            icon: 'ic_notification',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );

      debugPrint('PUSH: foreground local notification displayed.');
    } catch (error, stackTrace) {
      debugPrint('PUSH: local notification display failed: $error');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ---------------------------------------------------------
  // NOTIFICATION TAP HANDLING
  // ---------------------------------------------------------

  void _handleTap(RemoteMessage message) {
    debugPrint(
      'PUSH: notification tapped '
      '(${message.messageId ?? 'no id'}).',
    );

    _pendingTap = message;

    final router = _router;

    if (router != null) {
      _pendingTap = null;
      _navigateForMessage(message);
    }
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (error) {
      debugPrint('PUSH: could not decode local notification payload: $error');

      return null;
    }
  }

  void _handleTapData(Map<String, dynamic> data) {
    debugPrint(
      'PUSH: local notification data received '
      '(type=${data['type'] ?? 'unknown'}).',
    );

    _navigateForData(data);
  }

  void _navigateForMessage(RemoteMessage message) {
    final router = _router;

    if (router == null) return;

    final type = message.data['type']?.toString() ?? 'unknown';

    debugPrint('PUSH: routing notification tap (type=$type).');

    _navigateForData(message.data);
  }

  void _navigateForData(Map<String, dynamic> data) {
    final router = _router;

    if (router == null) return;

    final type = data['type']?.toString().toLowerCase() ?? '';

    final hasNotificationRoute =
        type.startsWith('job_') ||
        type.startsWith('invitation_') ||
        type.startsWith('message') ||
        type.startsWith('reminder') ||
        type.startsWith('offer') ||
        type.startsWith('promotion') ||
        type.startsWith('announcement') ||
        type == 'app_announcement';

    if (!hasNotificationRoute) {
      debugPrint('PUSH: no app route for notification type "$type".');

      return;
    }

    if (_config.isWorker) {
      router.pushNamed(RouteNames.workerNotifications);
      return;
    }

    router.pushNamed(RouteNames.employerNotifications);
  }

  // ---------------------------------------------------------
  // TOKEN REFRESH
  // ---------------------------------------------------------

  Future<void> _handleTokenRefresh(String token) async {
    _token = token;

    debugPrint('PUSH: FCM token refreshed.');

    final user = _supabase.auth.currentUser;

    if (user != null) {
      try {
        await _register(token, user.id);
      } catch (error, stackTrace) {
        debugPrint('PUSH: refreshed token registration failed: $error');

        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  // ---------------------------------------------------------
  // AUTH STATE CHANGES
  // ---------------------------------------------------------

  Future<void> _handleAuthState(AuthState state) async {
    try {
      final user = state.session?.user;

      if (_registeredUserId != null && _registeredUserId != user?.id) {
        await unregister();
      }

      if (user != null) {
        await registerForCurrentUser();
      }
    } catch (error, stackTrace) {
      debugPrint('PUSH: auth change handling failed: $error');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ---------------------------------------------------------
  // REGISTER CURRENT USER
  // ---------------------------------------------------------

  Future<void> registerForCurrentUser() async {
    if (!_initialized) return;

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        debugPrint('PUSH: no authenticated user; token registration skipped.');

        return;
      }

      final settings = await FirebaseMessaging.instance.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('PUSH: token registration skipped; permission denied.');

        return;
      }

      // ignore: deprecated_member_use
      final token = _token ?? await FirebaseMessaging.instance.getToken();

      if (token == null) {
        debugPrint('PUSH: FCM returned no token.');

        return;
      }

      _token = token;

      await _register(token, user.id);
    } catch (error, stackTrace) {
      debugPrint('PUSH: token registration failed: $error');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ---------------------------------------------------------
  // SUPABASE TOKEN REGISTRATION
  // ---------------------------------------------------------

  Future<void> _register(String token, String userId) async {
    await _supabase.from('user_device_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'app_flavor': _config.isWorker ? 'worker' : 'employer',
      'is_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,fcm_token');

    _registeredUserId = userId;

    debugPrint(
      'PUSH: FCM token registered in Supabase '
      'for authenticated user.',
    );
  }

  // ---------------------------------------------------------
  // UNREGISTER TOKEN
  // ---------------------------------------------------------

  Future<void> unregister() async {
    final token = _token;
    final userId = _registeredUserId;

    if (token != null && userId != null) {
      await _supabase
          .from('user_device_tokens')
          .delete()
          .eq('fcm_token', token)
          .eq('user_id', userId);
    }

    _registeredUserId = null;

    debugPrint('PUSH: previous authenticated user token unregistered.');
  }

  // ---------------------------------------------------------
  // CANCEL SUBSCRIPTIONS
  // ---------------------------------------------------------

  Future<void> _cancelSubscriptions() async {
    await _tokenRefreshSubscription?.cancel();
    await _authSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();

    _tokenRefreshSubscription = null;
    _authSubscription = null;
    _foregroundSubscription = null;
    _openedAppSubscription = null;
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------

  Future<void> dispose() async {
    await _cancelSubscriptions();

    _router = null;
    _initialized = false;

    debugPrint('PUSH: service disposed.');
  }
}
