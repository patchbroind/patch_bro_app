import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_benefit_entity.dart';

class EmployerBenefitHeaderCard extends StatelessWidget {
  const EmployerBenefitHeaderCard({super.key, required this.benefit});

  final EmployerBenefitEntity benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const _GiftIllustration(),
          const SizedBox(height: 12),
          Text(
            benefit.benefitTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete successful jobs as a Worker to unlock your Employer platform-fee benefit.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _GiftIllustration extends StatelessWidget {
  const _GiftIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: Image.asset(
        'assets/images/gift_box.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
