import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_empty_state.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_job_invitation_card.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerLatestInvitationSection extends StatelessWidget {
  const WorkerLatestInvitationSection({
    super.key,
    required this.invitation,
    required this.isLoading,
    required this.errorMessage,
    required this.respondingInvitationId,
    required this.onAccept,
    required this.onDecline,
  });

  final JobInvitationEntity? invitation;
  final bool isLoading;
  final String? errorMessage;
  final String? respondingInvitationId;
  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;

  @override
  Widget build(BuildContext context) {
    final cardPadding = const EdgeInsets.fromLTRB(16, 14, 16, 12);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.employerPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.employerPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Invitation',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You have a new job invitation',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  invitation == null
                      ? ''
                      : _relativeTime(invitation!.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    color: AppColors.employerPrimary,
                  ),
                ),
              )
            else if (errorMessage != null)
              AppEmptyState(
                layout: AppEmptyStateLayout.inline,
                message: errorMessage!,
                icon: Icons.info_outline_rounded,
                padding: const EdgeInsets.symmetric(vertical: 12),
                iconToContentSpacing: 10,
              )
            else if (invitation == null)
              const AppEmptyState(
                layout: AppEmptyStateLayout.inline,
                message: 'No active invitations right now.',
                icon: Icons.event_busy_rounded,
                padding: EdgeInsets.symmetric(vertical: 12),
                iconToContentSpacing: 10,
              )
            else
              WorkerJobInvitationCard(
                invitation: invitation!,
                respondingInvitationId: respondingInvitationId,
                onAccept: onAccept,
                onDecline: onDecline,
              ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final delta = DateTime.now().difference(dateTime);
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}
