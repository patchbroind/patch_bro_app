import 'package:flutter/material.dart';

/// Semantic colours owned by the Worker application.
///
/// Values intentionally match the existing Worker UI.  Worker Home has a
/// green campaign treatment while the rest of the current Worker flow uses
/// the established orange primary palette; keeping both here preserves that
/// design without borrowing Employer tokens.
abstract final class WorkerColors {
  WorkerColors._();

  static const primary = Color(0xFFF97316);
  static const primaryDark = Color(0xFF0F172A);
  static const primaryLight = Color(0xFFFFEDD5);
  static const secondary = Color(0xFFEA580C);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF7FAF7);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const textHint = Color(0xFF8B8E9D);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFE5E7EB);
  static const imagePlaceholder = Color(0xFFF3F4F6);
  static const imagePlaceholderIcon = Color(0xFF9CA3AF);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
  static const cardShadow = Color(0x0A000000);
  static const navigationShadow = Color(0x0F000000);

  // Worker Home's existing green visual treatment.
  static const homePrimary = Color(0xFF176B57);
  static const homePrimaryLight = Color(0xFFEAF7EF);
  static const homeBackground = Color(0xFFF4F7F2);
  static const homeHeaderBackground = Color(0xFFE9F5EA);
  static const homePromotionalBackground = Color(0xFFF1F9EE);
  static const homeNewBadgeBackground = Color(0xFFEAFBF1);
  static const homeCategoryBackground = Color(0xFFE8F6EF);
  static const homeDeclineBackground = Color(0xFFFEECEC);
  static const eliteBackgroundStart = Color(0xFF0F3D2E);
  static const eliteBackgroundEnd = Color(0xFF133E2F);
  static const eliteGold = Color(0xFFE5C974);
}
