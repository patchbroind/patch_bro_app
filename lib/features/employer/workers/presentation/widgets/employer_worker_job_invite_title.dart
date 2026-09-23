import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/date_time_utils.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';

class EmployerWorkerJobInviteTile extends StatelessWidget {
  const EmployerWorkerJobInviteTile({super.key, 
    required this.job,
    required this.isInvited,
    required this.isAccepted,
    required this.isLoading,
    required this.onInvite,
  });

  final EmployerJobEntity job;

  final bool isInvited;
  final bool isAccepted;
  final bool isLoading;

  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.skill,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StatusButton(
                isInvited: isInvited,
                isAccepted: isAccepted,
                isLoading: isLoading,
                onPressed: onInvite,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            job.category,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                DateTimeUtils.formatDate(job.date),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                DateTimeUtils.formatTime(job.time),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.isInvited,
    required this.isAccepted,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isInvited;
  final bool isAccepted;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isAccepted) {
      return _buildDisabled(label: 'Accepted', icon: Icons.check_circle_outline);
    }

    if (isInvited) {
      return _buildDisabled(label: 'Invited', icon: Icons.schedule_outlined);
    }

    return Expanded(
      child: SizedBox(
        height: 40,
        child: AppPrimaryButton(label: 'Invite',isLoading: isLoading,leadingIcon: Icon(Icons.send_outlined, size: 17), onPressed:isLoading ? null : onPressed)
      ),
    );
  }

  Widget _buildDisabled({required String label, required IconData icon}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
