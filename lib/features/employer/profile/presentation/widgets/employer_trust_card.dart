import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_profile_entity.dart';

class EmployerTrustCard extends StatelessWidget {
  const EmployerTrustCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final EmployerProfileEntity profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.employerLight.withValues(alpha: 0.55),
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
                  color: AppColors.employerPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  profile.isTrusted
                      ? Icons.verified_user_rounded
                      : Icons.shield_outlined,
                  color: AppColors.white,
                  size: 24,
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
                            'Trust & Reliability',
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
                      profile.isTrusted
                          ? 'Trusted Employer'
                          : 'Untrusted Employer',
                      style: TextStyle(
                        color: profile.isTrusted
                            ? AppColors.employerPrimary
                            : AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.successfulJobs} successful jobs • '
                      '${profile.cancelledJobs} cancellation'
                      '${profile.cancelledJobs == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Good standing with our community.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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