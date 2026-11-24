
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/app/start_up_failure_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'core/config/firebase_config.dart';
import 'core/network/supabase_config.dart';
import 'core/notifications/app_push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeAndRunApp();
  } catch (error, stackTrace) {
    debugPrint('PatchBro startup failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(StartupFailureApp(error: error));
  }
}

Future<void> _initializeAndRunApp() async {
  final config = AppConfig.fromEnvironment();

  debugPrint('========================================');
  debugPrint('PATCH BRO CONFIG');
  debugPrint('Flavor: ${config.flavor}');
  debugPrint('App: ${config.appName}');
  debugPrint('Supabase URL: ${SupabaseConfig.url}');
  debugPrint('========================================');

  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase configuration is missing. '
      'Please provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.',
    );
  }

  // Initialize Firebase with the correct flavor configuration.
  await Firebase.initializeApp(
    options: FirebaseConfig.optionsFor(config),
  );

  debugPrint(
    'Firebase initialized: ${Firebase.app().options.appId}',
  );

  // Register the background notification handler before runApp.
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // Initialize Supabase.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    ProviderScope(
      child: PatchBroApp(
        config: config,
      ),
    ),
  );
}


