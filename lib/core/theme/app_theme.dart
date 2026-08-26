import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import 'employer_theme.dart';
import 'worker_theme.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData fromFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.worker:
        return WorkerTheme.theme;

      case AppFlavor.employer:
        return EmployerTheme.theme;
    }
  }
}