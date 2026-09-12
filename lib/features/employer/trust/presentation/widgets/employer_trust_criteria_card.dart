import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_trust_entity.dart';

class EmployerTrustCriteriaCard extends StatelessWidget {
  const EmployerTrustCriteriaCard({
    super.key,
    required this.trust,
  });

  final EmployerTrustEntity trust;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_rounded, size: 23, color: AppColors.info),
              const SizedBox(width: 10),
              Text(
                'Trust Criteria',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _CriteriaItem(
            text: 'Achieve ${trust.successfulJobsRequired} successful jobs with correct payments.',
          ),
          const _CriteriaItem(text: 'Repeated cancellations may affect your trust status.'),
          _CriteriaItem(
            text: 'More than ${trust.maxCancellationsForTrust} cancellations can show Untrusted status.',
          ),
          _CriteriaItem(
            text: 'You can regain trust after ${trust.jobsRequiredToRegainTrust} clean completed jobs without cancellation.',
          ),
        ],
      ),
    );
  }
}

class _CriteriaItem extends StatelessWidget {
  const _CriteriaItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 4, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
