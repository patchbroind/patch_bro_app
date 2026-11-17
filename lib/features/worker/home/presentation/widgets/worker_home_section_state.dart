
import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_empty_state.dart';

class WorkerHomeSectionState extends StatelessWidget {
  const WorkerHomeSectionState({
    super.key,
    required this.child,
    required this.emptyMessage,
    required this.emptyIcon,
    this.isLoading = false,
    this.isEmpty = false,
    this.errorMessage,
    this.onRetry,
  });

  final Widget child;
  final bool isLoading;
  final bool isEmpty;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            color: WorkerColors.homePrimary,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: WorkerColors.error),
            const SizedBox(width: 10),
            Expanded(child: Text(errorMessage!)),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (isEmpty) {
      return AppEmptyState(
        layout: AppEmptyStateLayout.inline,
        message: emptyMessage,
        icon: emptyIcon,
        padding: const EdgeInsets.symmetric(vertical: 12),
        iconToContentSpacing: 10,
      );
    }

    return child;
  }
}
