import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.onRetry,
    this.title = 'Something went wrong',
    this.message = 'Please try again.',
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline_rounded,
    this.iconColor = AppColors.imagePlaceholderIcon,
  });

  final VoidCallback onRetry;

  final String title;
  final String message;
  final String retryLabel;

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: iconColor,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}