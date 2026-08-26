import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_theme.dart';

import 'config/app_config.dart';

class PatchBroApp extends StatelessWidget {
  const PatchBroApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       theme: AppTheme.fromFlavor(config.flavor),
      title: config.appName,
      home: Scaffold(
        body: Center(
          child: Text(
            config.appName,
          ),
        ),
      ),
    );
  }
}