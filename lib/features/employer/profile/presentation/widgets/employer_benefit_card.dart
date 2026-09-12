import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_profile_entity.dart';

class EmployerBenefitCard extends StatelessWidget {
  const EmployerBenefitCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final EmployerProfileEntity profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = profile.workerBenefitProgress;

    return Material(
      color: AppColors.info.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.info,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Employer Benefit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 21,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      profile.platformFeeBenefitEligible
                          ? 'Benefit unlocked'
                          : '${profile.qualifyingWorkerJobs} / '
                              '${profile.requiredWorkerJobs} '
                              'qualifying Worker jobs',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      profile.platformFeeBenefitEligible
                          ? 'Your Employer platform-fee benefit is active.'
                          : '${profile.remainingWorkerJobs} more '
                              'job${profile.remainingWorkerJobs == 1 ? '' : 's'} '
                              'to unlock your Employer platform-fee benefit.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}