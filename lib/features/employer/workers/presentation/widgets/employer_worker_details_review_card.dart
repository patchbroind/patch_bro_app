import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerWorkerDetailsReviewCard extends StatelessWidget {
  const EmployerWorkerDetailsReviewCard({
    super.key,
    this.reviewer = 'Akhil Varma',
    this.text =
        'Excellent work! Very professional and completed the job on time.',
    this.rating = 5.0,
  });

  final String reviewer;
  final String text;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                child: Icon(
                  Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reviewer,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}