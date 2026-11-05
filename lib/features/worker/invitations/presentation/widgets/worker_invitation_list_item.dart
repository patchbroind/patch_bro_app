import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_primary_filled_icon_button.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_invitation_info_row.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitation_status_badge.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerInvitationListItem extends StatelessWidget {
  const WorkerInvitationListItem({
    super.key,
    required this.invitation,
    required this.isExpired,
    required this.respondingInvitationId,
    required this.respondingAction,
    required this.onAccept,
    required this.onDecline,
    required this.onViewDetails,
  });

  final JobInvitationEntity invitation;
  final bool isExpired;
  final String? respondingInvitationId;
  final InvitationResponseAction? respondingAction;

  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final isResponding = respondingInvitationId == invitation.id;

    final isAccepting =
        isResponding && respondingAction == InvitationResponseAction.accept;

    final isDeclining =
        isResponding && respondingAction == InvitationResponseAction.decline;

    final title = invitation.jobSkill.trim().isNotEmpty
        ? invitation.jobSkill
        : invitation.jobCategory;

    final location = invitation.locationAddress.trim().isEmpty
        ? 'Location unavailable'
        : invitation.locationAddress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WorkerColors.border),
        boxShadow: const [
          BoxShadow(
            color: WorkerColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: WorkerColors.homePrimaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  size: 29,
                  color: WorkerColors.homePrimary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'Job invitation' : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: WorkerColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 9),
                    WorkerInvitationInfoRow(
                      icon: Icons.location_on_outlined,
                      text: location,
                    ),
                    const SizedBox(height: 7),
                    WorkerInvitationInfoRow(
                      icon: Icons.calendar_month_outlined,
                      text: _scheduledDate,
                    ),
                    const SizedBox(height: 7),
                    WorkerInvitationInfoRow(
                      icon: Icons.access_time_rounded,
                      text: invitation.scheduledTime.isEmpty
                          ? 'Time unavailable'
                          : invitation.scheduledTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              WorkerInvitationStatusBadge(
                label: isExpired ? 'Expired' : 'Pending',
                isExpired: isExpired,
              ),
            ],
          ),
          if (invitation.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              invitation.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WorkerColors.textSecondary,
                    height: 1.4,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: WorkerColors.divider),
          const SizedBox(height: 13),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 15,
                color: WorkerColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Received ${_relativeTime(invitation.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: WorkerColors.textSecondary,
                      ),
                ),
              ),
              TextButton(
                onPressed: onViewDetails,
                child: const Text(
                  'View details',
                  style: TextStyle(
                    color: WorkerColors.homePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (!isExpired) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryFilledIconButton(
                    label: 'Decline',
                    icon: Icons.close_rounded,
                    onPressed: isResponding
                        ? null
                        : () => onDecline(invitation.id),
                    isLoading: isDeclining,
                    backgroundColor: WorkerColors.surface,
                    foregroundColor: WorkerColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppPrimaryFilledIconButton(
                    label: 'Accept',
                    icon: Icons.check_rounded,
                    onPressed: isResponding
                        ? null
                        : () => onAccept(invitation.id),
                    isLoading: isAccepting,
                    backgroundColor: WorkerColors.homePrimary,
                    foregroundColor: WorkerColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String get _scheduledDate {
    final date = invitation.scheduledDate;

    if (date == null) return 'Date unavailable';

    return DateFormat('EEE, d MMM').format(date);
  }

  String _relativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';

    return '${difference.inDays}d ago';
  }
}