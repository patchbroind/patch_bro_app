import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class PostJobWorkerLoadError extends StatelessWidget {
  const PostJobWorkerLoadError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 350,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 38,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}