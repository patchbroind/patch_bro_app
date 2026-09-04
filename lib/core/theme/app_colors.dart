import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ============================================================
  // Common Colors
  // ============================================================

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const black87 = Color(0xDE000000);
  static const black54 = Color(0x8A000000);

  static const background = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFF9CA3AF);
  static const textHint = Color(0xFF8B8E9D);
  static const textMuted = Color(0xFF777B88);
  static const textTertiary = Color(0xFF737685);

  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFE5E7EB);

  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF2563EB);
  static const googleBlue = Color(0xFF4285F4);
  static const socialBorder = Color(0xFFE0E0E0);

  // ============================================================
  // Employer Colors
  // ============================================================

  /// Main emerald green used throughout the Employer app.
  static const employerPrimary = Color(0xFF176B57);

  /// Very dark green used for gradients, buttons and backgrounds.
  static const employerDark = Color(0xFF001B17);

  /// Lighter green for secondary elements.
  static const employerSecondary = Color(0xFF2A8A72);

  /// Soft green for backgrounds/highlights.
  static const employerLight = Color(0xFFDDF3EC);

  // ============================================================
  // Worker Colors
  // ============================================================

  /// Main orange used throughout the Worker app.
  static const workerPrimary = Color(0xFFF97316);

  /// Deep navy used as the Worker dark brand color.
  static const workerDark = Color(0xFF0F172A);

  /// Secondary orange.
  static const workerSecondary = Color(0xFFEA580C);

  /// Soft orange for backgrounds/highlights.
  static const workerLight = Color(0xFFFFEDD5);
}
