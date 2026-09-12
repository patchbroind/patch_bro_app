import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_benefit_entity.dart';

class EmployerBenefitProgressCard extends StatelessWidget {
  const EmployerBenefitProgressCard({super.key, required this.benefit});

  final EmployerBenefitEntity benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            benefit.progressLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text('qualifying Worker jobs', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 14,
              value: benefit.progress,
              backgroundColor: AppColors.border,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            benefit.isEligible
                ? 'Your Employer fee benefit is unlocked.'
                : benefit.remainingJobsDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}
