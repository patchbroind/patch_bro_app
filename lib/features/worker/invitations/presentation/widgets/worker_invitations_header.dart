import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerInvitationsHeader extends StatelessWidget {
  const WorkerInvitationsHeader({
    super.key,
    this.onSearch,
    this.onFilter,
  });

  final VoidCallback? onSearch;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Material(
            color: WorkerColors.homePrimaryLight,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: WorkerColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invitations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: WorkerColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage your job invitations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WorkerColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          _HeaderAction(
            icon: Icons.search_rounded,
            onPressed: onSearch,
          ),
          const SizedBox(width: 8),
          _HeaderAction(
            icon: Icons.tune_rounded,
            onPressed: onFilter,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WorkerColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: WorkerColors.cardShadow,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: WorkerColors.textPrimary,
          size: 21,
        ),
      ),
    );
  }
}