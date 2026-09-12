import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_tappable_card.dart';

import '../../domain/entities/employer_job_entity.dart';
import 'employer_job_image.dart';

class EmployerJobCard extends StatelessWidget {
  const EmployerJobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  final EmployerJobEntity job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (job.status) {
      EmployerJobStatus.completed => AppColors.success,
      EmployerJobStatus.active => AppColors.info,
      EmployerJobStatus.cancelled => AppColors.textSecondary,
    };

    final dateLabel =
        MaterialLocalizations.of(context).formatMediumDate(job.date);

    final amountLabel = '${job.currency} ${job.amount.toStringAsFixed(2)}';

    return Container(
      decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
      child: AppTappableCard(
        onTap: onTap,
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -----------------------------------------------------------------
            // Job Image
            // -----------------------------------------------------------------
            EmployerJobImage(
              imageUrl: job.imageUrl,
            ),
      
            const SizedBox(width: 10),
      
            // -----------------------------------------------------------------
            // Main Content
            // -----------------------------------------------------------------
            Expanded(
              child: SizedBox(
                height: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Job title
                    Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                    ),
      
                    const SizedBox(height: 3),
      
                    // Category
                    Text(
                      job.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
      
                    const SizedBox(height: 2),
      
                    // Date
                    Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),
      
            const SizedBox(width: 8),
      
            // -----------------------------------------------------------------
            // Right Side
            // -----------------------------------------------------------------
            SizedBox(
              width: 72,
              height: 56,
              child: Stack(
                children: [
                  // Status badge - Top Right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _StatusBadge(
                      label: job.statusLabel,
                      color: statusColor,
                    ),
                  ),
      
                  // Amount - Bottom Right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      amountLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ),
      
            const SizedBox(width: 5),
      
            // -----------------------------------------------------------------
            // Chevron
            // -----------------------------------------------------------------
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 72,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}