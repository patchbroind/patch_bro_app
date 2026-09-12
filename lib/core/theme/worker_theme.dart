import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

abstract final class WorkerTheme {
  WorkerTheme._();

  static ThemeData get theme {
    return AppTheme.light(
      primary: AppColors.workerPrimary,
      secondary: AppColors.workerSecondary,
    );
  }
}
