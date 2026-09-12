import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_benefit_entity.dart';

class EmployerBenefitInfoCard extends StatelessWidget {
  const EmployerBenefitInfoCard({super.key, required this.benefit});

  final EmployerBenefitEntity benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.info),
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.percent_rounded, size: 18, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's the benefit?",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  benefit.benefitDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
