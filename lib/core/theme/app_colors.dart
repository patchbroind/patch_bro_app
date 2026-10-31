import 'package:flutter/material.dart';

import 'employer/employer_colors.dart';
import 'worker/worker_colors.dart';

abstract final class AppColors {
  AppColors._();

  // ============================================================
  // Common Colors
  // ============================================================

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const black87 = Color(0xDE000000);
  static const black54 = Color(0x8A000000);

  static const transparent = Colors.transparent;

  static const background = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFF9CA3AF);
  static const textHint = Color(0xFF8B8E9D);
  static const textMuted = Color(0xFF777B88);
  static const textTertiary = Color(0xFF737685);

  static const surface = Color(0xFFFFFFFF);
  static const shadow = Color(0x1F000000);
  static const imagePlaceholder = Color(0xFFF3F4F6);
  static const imagePlaceholderIcon = Color(0xFF9CA3AF);
  static const carouselOverlay = Color(0xB8000000);
  static const carouselSubtitle = Color(0xE6FFFFFF);

  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFE5E7EB);

  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF2563EB);
  static const googleBlue = Color(0xFF4285F4);
  static const socialBorder = Color(0xFFE0E0E0);

  // Compatibility aliases for older feature code. The canonical definitions
  // live in the flavor-owned classes above; new Worker/Employer UI must use
  // those classes directly.
  static const employerPrimary = EmployerColors.primary;
  static const employerDark = EmployerColors.primaryDark;
  static const employerSecondary = EmployerColors.secondary;
  static const employerLight = EmployerColors.primaryLight;

  static const workerPrimary = WorkerColors.primary;
  static const workerDark = WorkerColors.primaryDark;
  static const workerSecondary = WorkerColors.secondary;
  static const workerLight = WorkerColors.primaryLight;
}
