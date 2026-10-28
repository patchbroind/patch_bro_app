import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_network_image.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/meta_line.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerJobInvitationCard extends StatelessWidget {
  const WorkerJobInvitationCard({super.key, 
    required this.invitation,
    required this.respondingInvitationId,
    required this.onAccept,
    required this.onDecline,
  });

  final JobInvitationEntity invitation;
  final String? respondingInvitationId;
  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;

  @override
  Widget build(BuildContext context) {
    final hasChip = invitation.jobCategory.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
                  backgroundColor: AppColors.imagePlaceholder,
                  fallback: const Icon(Icons.work_outline_rounded, color: AppColors.textSecondary),
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
                            invitation.jobCategory.isNotEmpty ? invitation.jobCategory : invitation.jobSkill,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        if (invitation.isPending)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAFBF1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('New', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    if (hasChip)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6EF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            invitation.jobCategory,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.employerPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    MetaLine(icon: Icons.location_on_outlined, text: invitation.locationAddress.isNotEmpty ? invitation.locationAddress : 'Location unavailable'),
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
                      text: invitation.scheduledTime.isNotEmpty ? invitation.scheduledTime : 'Time unavailable',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: respondingInvitationId == invitation.id ? null : () => onDecline(invitation.id),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFEECEC),
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: respondingInvitationId == invitation.id ? null : () => onAccept(invitation.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.employerPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept Invitation'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}