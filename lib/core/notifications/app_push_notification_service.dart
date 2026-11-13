
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:patch_bro/core/config/firebase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/config/app_config.dart';

import '../../firebase_options_worker.dart' as worker_firebase;
import '../../firebase_options_employer.dart' as employer_firebase;

// Select Firebase configuration based on app flavor.
FirebaseOptions _firebaseOptionsFor(AppConfig config) {
  return config.isWorker
      ? worker_firebase.DefaultFirebaseOptions.currentPlatform
      : employer_firebase.DefaultFirebaseOptions.currentPlatform;
}

// Background notification handler.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  if (Firebase.apps.isEmpty) {
    final config = AppConfig.fromEnvironment();

    await Firebase.initializeApp(
      options: FirebaseConfig.optionsFor(config),
    );
  }

  debugPrint(
    'Background notification received: ${message.messageId}',
  );
}

class AppPushNotificationService {
  AppPushNotificationService(this._supabase, this._config);

  final SupabaseClient _supabase;
  final AppConfig _config;

  bool _initialized = false;
  String? _registeredUserId;
  String? _token;

  Future<void> initialize() async {
    if (_initialized ||
        kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    try {
      // Normally Firebase is already initialized in main.dart.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: _firebaseOptionsFor(_config),
        );
      }

      _initialized = true;

      // Listen for token refresh.
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        _token = token;

        final user = _supabase.auth.currentUser;

        if (user != null) {
          await _register(token, user.id);
        }
      });

      // Listen for Supabase authentication changes.
      _supabase.auth.onAuthStateChange.listen((event) async {
        final user = event.session?.user;
        final oldUser = _registeredUserId;

        if (oldUser != null && oldUser != user?.id) {
          await unregister();
        }

        if (user != null) {
          await registerForCurrentUser();
        }
      });

      // Register the current logged-in user.
      await registerForCurrentUser();

      debugPrint('Push notification service initialized');
    } on FirebaseException catch (error) {
      debugPrint(
        'Push notifications unavailable: ${error.code}',
      );
    } catch (error) {
      debugPrint(
        'Push notification setup unavailable: $error',
      );
    }
  }

  Future<void> registerForCurrentUser() async {
    if (!_initialized) return;

    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final settings =
        await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }

    final token =
        _token ?? await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    _token = token;

    await _register(token, user.id);
  }

  Future<void> _register(String token, String userId) async {
    await _supabase.from('user_device_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'app_flavor': _config.isWorker ? 'worker' : 'employer',
      'is_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'fcm_token');

    _registeredUserId = userId;

    debugPrint('FCM token registered for user: $userId');
  }

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
  }
}
