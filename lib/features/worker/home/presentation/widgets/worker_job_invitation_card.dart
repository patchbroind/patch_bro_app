import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_network_image.dart';
import 'package:patch_bro/core/widgets/app_primary_filled_icon_button.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/meta_line.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerJobInvitationCard extends StatelessWidget {
  const WorkerJobInvitationCard({
    super.key,
    required this.invitation,
    required this.respondingInvitationId,
    required this.respondingAction,
    required this.onAccept,
    required this.onDecline,
  });

  final JobInvitationEntity invitation;
  final String? respondingInvitationId;
  final InvitationResponseAction? respondingAction;

  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;

  @override
  Widget build(BuildContext context) {
    final hasChip = invitation.jobCategory.trim().isNotEmpty;

    final isResponding = respondingInvitationId == invitation.id;

    final isAccepting = isResponding && respondingAction == InvitationResponseAction.accept;

    final isDeclining = isResponding && respondingAction == InvitationResponseAction.decline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WorkerColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WorkerColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppNetworkImage(
                  imageUrl: invitation.workerAvatarUrl,
                  width: 74,
                  height: 74,
                  fit: BoxFit.cover,
                  backgroundColor: WorkerColors.imagePlaceholder,
                  fallback: const Icon(
                    Icons.work_outline_rounded,
                    color: WorkerColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            invitation.jobCategory.isNotEmpty
                                ? invitation.jobCategory
                                : invitation.jobSkill,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: WorkerColors.textPrimary,
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (invitation.isPending)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: WorkerColors.homeNewBadgeBackground,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: WorkerColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                            Text(
                              _relativeTime(invitation.createdAt),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: WorkerColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (hasChip)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: WorkerColors.homeCategoryBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            invitation.jobCategory,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: WorkerColors.homePrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    MetaLine(
                      icon: Icons.location_on_outlined,
                      text: invitation.locationAddress.isNotEmpty
                          ? invitation.locationAddress
                          : 'Location unavailable',
                    ),

                    const SizedBox(height: 4),

                    MetaLine(
                      icon: Icons.calendar_month_outlined,
                      text: invitation.scheduledDate == null
                          ? 'Date unavailable'
                          : DateFormat('EEE, d MMM').format(invitation.scheduledDate!),
                    ),

                    const SizedBox(height: 4),

                    MetaLine(
                      icon: Icons.access_time_rounded,
                      text: invitation.scheduledTime.isNotEmpty
                          ? invitation.scheduledTime
                          : 'Time unavailable',
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: WorkerColors.textSecondary),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // DECLINE BUTTON
              Expanded(
                child: AppPrimaryFilledIconButton(
                  label: 'Decline',
                  icon: Icons.close_rounded,
                  onPressed: isResponding ? null : () => onDecline(invitation.id),
                  isLoading: isDeclining,
                  backgroundColor: WorkerColors.homeDeclineBackground,
                  foregroundColor: WorkerColors.error,
                ),
              ),

              const SizedBox(width: 10),

              // ACCEPT BUTTON
              Expanded(
                child: AppPrimaryFilledIconButton(
                  label: 'Accept',
                  icon: Icons.check_rounded,
                  onPressed: isResponding ? null : () => onAccept(invitation.id),
                  isLoading: isAccepting,
                  backgroundColor: WorkerColors.homePrimary,
                  foregroundColor: WorkerColors.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final delta = DateTime.now().difference(dateTime);

    if (delta.inMinutes < 60) {
      return '${delta.inMinutes}m ago';
    }

    if (delta.inHours < 24) {
      return '${delta.inHours}h ago';
    }

    return '${delta.inDays}d ago';
  }
}
