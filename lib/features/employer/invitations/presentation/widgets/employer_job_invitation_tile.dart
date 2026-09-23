import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/invitations/presentation/widgets/employer_job_invitation_expirey_text.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class EmploterJobInvitationTile
    extends StatelessWidget {
  const EmploterJobInvitationTile({super.key, 
    required this.invitation,
  });

  final JobInvitationEntity 
      invitation;

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        _statusColor(
      invitation.status,
    );

    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.06),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage:
                invitation
                            .workerAvatarUrl !=
                        null
                    ? NetworkImage(
                        invitation
                            .workerAvatarUrl!,
                      )
                    : null,
            child:
                invitation.workerAvatarUrl ==
                        null
                    ? Text(
                        invitation
                                .workerName
                                .isNotEmpty
                            ? invitation
                                .workerName[0]
                                .toUpperCase()
                            : '?',
                      )
                    : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  invitation
                      .workerName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  invitation
                      .statusLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                if (invitation.isActive)
                  const SizedBox(
                    height: 3,
                  ),
                if (invitation.isActive)
                  InvitationExpiryText(
                    expiresAt:
                        invitation
                            .expiresAt,
                  ),
              ],
            ),
          ),

          Icon(
            _statusIcon(
              invitation.status,
            ),
            color: color,
          ),
        ],
      ),
    );
  }

  Color _statusColor(
    JobInvitationStatus status,
  ) {
    switch (status) {
      case JobInvitationStatus.accepted:
        return AppColors.success;
      case JobInvitationStatus.rejected:
        return AppColors.error;
      case JobInvitationStatus.expired:
        return AppColors.textSecondary;
      case JobInvitationStatus.cancelled:
        return AppColors.textSecondary;
      case JobInvitationStatus.pending:
        return AppColors.info;
    }
  }

  IconData _statusIcon(
    JobInvitationStatus status,
  ) {
    switch (status) {
      case JobInvitationStatus.accepted:
        return Icons.check_circle_rounded;
      case JobInvitationStatus.rejected:
        return Icons.cancel_outlined;
      case JobInvitationStatus.expired:
        return Icons.timer_off_outlined;
      case JobInvitationStatus.cancelled:
        return Icons.block_outlined;
      case JobInvitationStatus.pending:
        return Icons.schedule_rounded;
    }
  }
}