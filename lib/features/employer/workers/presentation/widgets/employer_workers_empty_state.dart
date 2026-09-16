import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerWorkersEmptyState extends StatelessWidget {
  const EmployerWorkersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 54,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'No workers found',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing your search or filters.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
