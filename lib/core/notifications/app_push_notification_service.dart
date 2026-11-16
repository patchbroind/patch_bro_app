
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/config/app_config.dart';
import '../../firebase_options_employer.dart' as employer_firebase;
import '../../firebase_options_worker.dart' as worker_firebase;
import '../config/firebase_config.dart';

// Select Firebase configuration based on app flavor.
FirebaseOptions _firebaseOptionsFor(AppConfig config) {
  return config.isWorker
      ? worker_firebase.DefaultFirebaseOptions.currentPlatform
      : employer_firebase.DefaultFirebaseOptions.currentPlatform;
}

// Android notification channel.
const AndroidNotificationChannel _notificationChannel =
    AndroidNotificationChannel(
  'patchbro_high_importance',
  'Patch Bro Notifications',
  description: 'Notifications about jobs, invitations and updates.',
  importance: Importance.max,
  playSound: true,
);

// Local notification plugin.
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// Background notification handler.
// Must be registered in main.dart before runApp().
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    if (Firebase.apps.isEmpty) {
      final config = AppConfig.fromEnvironment();

      await Firebase.initializeApp(
        options: FirebaseConfig.optionsFor(config),
      );
    }

    debugPrint('========== BACKGROUND FCM RECEIVED ==========');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  } catch (error, stackTrace) {
    debugPrint('Background FCM handler failed: $error');
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

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  Future<void> initialize() async {
    if (_initialized ||
        kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    debugPrint('========================================');
    debugPrint('PUSH SERVICE: INITIALIZATION STARTED');
    debugPrint('Flavor: ${_config.flavor}');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint('========================================');

    try {
      // Initialize Firebase if not already initialized.
      if (Firebase.apps.isEmpty) {
        debugPrint('PUSH SERVICE: Initializing Firebase...');

        await Firebase.initializeApp(
          options: _firebaseOptionsFor(_config),
        );
      }

      debugPrint(
        'PUSH SERVICE: Firebase initialized: '
        '${Firebase.app().options.appId}',
      );

      // Initialize local notifications.
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('LOCAL NOTIFICATION TAPPED');
          debugPrint('Payload: ${response.payload}');
        },
      );

      debugPrint('PUSH SERVICE: Local notifications initialized');

      // Create Android notification channel.
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        _notificationChannel,
      );

      debugPrint('PUSH SERVICE: Android notification channel created');

      // Request notification permission.
      final settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'PUSH SERVICE: Notification permission: '
        '${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus ==
          AuthorizationStatus.denied) {
        debugPrint('PUSH SERVICE: Notification permission denied.');
      }

      // Enable foreground notification presentation on iOS.
      if (Platform.isIOS) {
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Allow callbacks to use the service.
      _initialized = true;

      // Listen for foreground FCM messages.
      debugPrint('PUSH SERVICE: Registering foreground listener...');

      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        (message) {
          debugPrint('PUSH SERVICE: onMessage TRIGGERED');
          _handleForegroundMessage(message);
        },
        onError: (error) {
          debugPrint('PUSH SERVICE: Foreground listener error: $error');
        },
      );

      debugPrint('PUSH SERVICE: Foreground listener registered');

      // Listen for notification taps when app is in background.
      _openedAppSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          debugPrint('PUSH SERVICE: Notification opened');
          debugPrint('Message ID: ${message.messageId}');
          debugPrint('Data: ${message.data}');
        },
        onError: (error) {
          debugPrint('PUSH SERVICE: Notification tap error: $error');
        },
      );

      // Check whether the app was launched by tapping a notification.
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('PUSH SERVICE: App launched from notification');
        debugPrint('Initial message: ${initialMessage.data}');
      }

      // Listen for FCM token refresh.
      _tokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) async {
          debugPrint('PUSH SERVICE: FCM token refreshed');

          _token = token;

          final user = _supabase.auth.currentUser;

          if (user != null) {
            await _register(token, user.id);
          }
        },
        onError: (error) {
          debugPrint('PUSH SERVICE: Token refresh error: $error');
        },
      );

      // Listen for Supabase authentication changes.
      _authSubscription = _supabase.auth.onAuthStateChange.listen(
        (event) async {
          try {
            final user = event.session?.user;
            final oldUser = _registeredUserId;

            debugPrint(
              'PUSH SERVICE: Auth event: ${event.event}',
            );

            if (oldUser != null && oldUser != user?.id) {
              await unregister();
            }

            if (user != null) {
              await registerForCurrentUser();
            }
          } catch (error, stackTrace) {
            debugPrint('PUSH SERVICE: Auth listener failed: $error');
            debugPrintStack(stackTrace: stackTrace);
          }
        },
        onError: (error) {
          debugPrint('PUSH SERVICE: Auth listener error: $error');
        },
      );

      // Register the currently logged-in user.
      await registerForCurrentUser();

      debugPrint('========================================');
      debugPrint('PUSH SERVICE: INITIALIZATION COMPLETED');
      debugPrint('========================================');
    } catch (error, stackTrace) {
      _initialized = false;

      debugPrint('PUSH SERVICE: INITIALIZATION FAILED');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Handles notifications received while the app is open.
  Future<void> _handleForegroundMessage(
    RemoteMessage message,
  ) async {
    debugPrint('========== FCM RECEIVED ==========');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    if (!Platform.isAndroid) {
      debugPrint(
        'PUSH SERVICE: Android local notification not required.',
      );
      return;
    }

    final title = message.notification?.title ??
        message.data['title']?.toString();

    final body = message.notification?.body ??
        message.data['message']?.toString() ??
        message.data['body']?.toString();

    if ((title == null || title.isEmpty) &&
        (body == null || body.isEmpty)) {
      debugPrint(
        'PUSH SERVICE: Message has no title or body.',
      );
      return;
    }

    final notificationId =
        (message.messageId?.hashCode ??
                DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff;

    try {
      await _localNotifications.show(
        id: notificationId,
        title: title ?? 'Patch Bro',
        body: body ?? 'You have a new notification.',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _notificationChannel.id,
            _notificationChannel.name,
            channelDescription: _notificationChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: message.data.toString(),
      );

      debugPrint(
        'PUSH SERVICE: FOREGROUND LOCAL NOTIFICATION DISPLAYED',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'PUSH SERVICE: LOCAL NOTIFICATION DISPLAY FAILED',
      );
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Registers the current Supabase user's FCM token.
  Future<void> registerForCurrentUser() async {
    if (!_initialized) {
      debugPrint('PUSH SERVICE: Service is not initialized.');
      return;
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        debugPrint(
          'PUSH SERVICE: No logged-in user. Skipping registration.',
        );
        return;
      }

      debugPrint('PUSH SERVICE: Registering FCM token...');
      debugPrint('PUSH SERVICE: Supabase user ID: ${user.id}');

      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      debugPrint(
        'PUSH SERVICE: Current permission: '
        '${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus ==
          AuthorizationStatus.denied) {
        debugPrint('PUSH SERVICE: Permission denied.');
        return;
      }

      final token =
          _token ?? await FirebaseMessaging.instance.getToken();

      if (token == null) {
        debugPrint('PUSH SERVICE: FCM token is null.');
        return;
      }

      _token = token;

      debugPrint('PUSH SERVICE: FCM token obtained.');
      debugPrint(
        'PUSH SERVICE: Token suffix: '
        '${token.length > 10 ? token.substring(token.length - 10) : token}',
      );

      await _register(token, user.id);
    } catch (error, stackTrace) {
      debugPrint('PUSH SERVICE: Token registration failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Saves the FCM token in Supabase.
  Future<void> _register(
    String token,
    String userId,
  ) async {
    debugPrint('PUSH SERVICE: Saving FCM token to Supabase...');

    await _supabase.from('user_device_tokens').upsert(
      {
        'user_id': userId,
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'app_flavor': _config.isWorker ? 'worker' : 'employer',
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,fcm_token',
    );

    _registeredUserId = userId;

    debugPrint('PUSH SERVICE: FCM TOKEN REGISTERED SUCCESSFULLY');
    debugPrint('PUSH SERVICE: Registered user ID: $userId');
  }

  // Removes the old user's device token.
  Future<void> unregister() async {
    final token = _token;
    final userId = _registeredUserId;

    if (token != null && userId != null) {
      debugPrint('PUSH SERVICE: Unregistering previous user token...');

      await _supabase
          .from('user_device_tokens')
          .delete()
          .eq('fcm_token', token)
          .eq('user_id', userId);
    }

    _registeredUserId = null;

    debugPrint('PUSH SERVICE: Previous user token unregistered.');
  }

  // Cancel subscriptions when the service is no longer needed.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _authSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();

    _initialized = false;

    debugPrint('PUSH SERVICE: Disposed.');
  }
}
