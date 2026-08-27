import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';

class PatchBroApp extends StatelessWidget {
  const PatchBroApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create(
      config: config,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: config.appName,
      theme: AppTheme.fromFlavor(config.flavor),
      routerConfig: router,
    );
  }
}