import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_profile_entity.dart';

class EmployerProfileStats extends StatelessWidget {
  const EmployerProfileStats({
    super.key,
    required this.profile,
  });

  final EmployerProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.description_outlined,
                iconColor: AppColors.info,
                value: profile.jobsPosted,
                label: 'Jobs Posted',
              ),
            ),
            const VerticalDivider(
              width: 1,
              color: AppColors.divider,
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
                value: profile.jobsCompleted,
                label: 'Completed',
              ),
            ),
            const VerticalDivider(
              width: 1,
              color: AppColors.divider,
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.cancel_outlined,
                iconColor: AppColors.error,
                value: profile.cancelledJobs,
                label: 'Cancelled',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(height: 7),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}