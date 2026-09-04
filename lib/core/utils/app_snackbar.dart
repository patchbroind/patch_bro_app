import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static const Duration _defaultDuration = Duration(seconds: 3);

  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: AppColors.success,
    );
  }

  static void error(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.error_outline, backgroundColor: AppColors.error);
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.warning,
    );
  }

  static void info(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.info_outline, backgroundColor: AppColors.info);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = _defaultDuration,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: AppColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: const TextStyle(color: AppColors.white, fontSize: 14)),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }
}
