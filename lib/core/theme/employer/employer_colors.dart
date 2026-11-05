import 'package:flutter/material.dart';

/// Semantic colours owned by the Employer application.
///
/// These values retain the established Employer appearance, independently of
/// the Worker palette.
abstract final class EmployerColors {
  EmployerColors._();

  static const primary = Color(0xFF176B57);
  static const primaryDark = Color(0xFF001B17);
  static const secondary = Color(0xFF2A8A72);
  static const primaryLight = Color(0xFFDDF3EC);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const textHint = Color(0xFF8B8E9D);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFE5E7EB);
  static const error = Color(0xFFDC2626);
}
