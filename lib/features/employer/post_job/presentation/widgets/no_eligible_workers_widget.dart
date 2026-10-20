import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class NoEligibleWorkersWidget extends StatelessWidget {
  const NoEligibleWorkersWidget({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 350,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded, size: 42, color: AppColors.employerPrimary),
          const SizedBox(height: 12),
          Text(
            'No eligible workers found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try adjusting the selected category or required skill.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}