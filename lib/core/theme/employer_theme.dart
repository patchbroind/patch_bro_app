import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

abstract final class EmployerTheme {
  EmployerTheme._();

  static ThemeData get theme {
    return AppTheme.light(
      primary: AppColors.employerPrimary,
      secondary: AppColors.employerSecondary,
    );
  }
}
