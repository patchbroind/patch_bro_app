import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_tappable_card.dart';
import 'package:patch_bro/core/widgets/job_status_badge.dart';

import '../../domain/entities/employer_job_entity.dart';
import 'employer_job_image.dart';

class EmployerJobCard extends StatelessWidget {
  const EmployerJobCard({super.key, required this.job, this.onTap});

  final EmployerJobEntity job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (job.status) {
      EmployerJobStatus.completed => AppColors.success,

      EmployerJobStatus.active => AppColors.info,

      EmployerJobStatus.cancelled => AppColors.textSecondary,
    };

    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(job.date);

    final timeLabel = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(job.time));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppTappableCard(
        onTap: onTap,
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EmployerJobImage(imageUrl: job.imageUrl),

            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

                    Text(
                      job.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 10),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '$dateLabel • $timeLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              width: 72,
              height: 56,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: JobStatusBadge(
                      label: job.statusLabel,
                      color: statusColor,
                      horizontalPadding: 6,
                      verticalPadding:3,
                      labelStyle: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Text(
                      job.locationAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}


