import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'worker_colors.dart';

abstract final class WorkerTheme {
  WorkerTheme._();

  static ThemeData get theme => AppTheme.light(
    primary: WorkerColors.primary,
    secondary: WorkerColors.secondary,
    background: WorkerColors.background,
    surface: WorkerColors.surface,
    textPrimary: WorkerColors.textPrimary,
    textSecondary: WorkerColors.textSecondary,
    textMuted: WorkerColors.textMuted,
    border: WorkerColors.border,
    divider: WorkerColors.divider,
    error: WorkerColors.error,
  );
}
