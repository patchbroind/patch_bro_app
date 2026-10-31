import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'employer_colors.dart';

abstract final class EmployerTheme {
  EmployerTheme._();

  static ThemeData get theme => AppTheme.light(
    primary: EmployerColors.primary,
    secondary: EmployerColors.secondary,
    background: EmployerColors.background,
    surface: EmployerColors.surface,
    textPrimary: EmployerColors.textPrimary,
    textSecondary: EmployerColors.textSecondary,
    textMuted: EmployerColors.textMuted,
    border: EmployerColors.border,
    divider: EmployerColors.divider,
    error: EmployerColors.error,
  );
}
