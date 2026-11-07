import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerInvitationEmptyState extends StatelessWidget {
  const WorkerInvitationEmptyState({
    super.key,
    required this.isExpired,
  });

  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 55,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: WorkerColors.homePrimaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isExpired
                  ? Icons.history_rounded
                  : Icons.mail_outline_rounded,
              size: 35,
              color: WorkerColors.homePrimary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isExpired
                ? 'No expired invitations'
                : 'No active invitations',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: WorkerColors.textPrimary,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            isExpired
                ? 'Your expired invitations will appear here.'
                : 'When employers invite you for a job, you will see it here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WorkerColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}