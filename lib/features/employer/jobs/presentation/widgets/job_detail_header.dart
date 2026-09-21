import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/job_status_badge.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_card_container.dart';

class JobDetailHeader extends StatelessWidget {
  const JobDetailHeader({super.key, 
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        switch (job.status) {
      EmployerJobStatus.active =>
        AppColors.info,
      EmployerJobStatus.completed =>
        AppColors.success,
      EmployerJobStatus.cancelled =>
        AppColors.textSecondary,
    };

    return JobDetailCardContainer(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.category,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                        fontWeight:
                            FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.skill,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          JobStatusBadge(
            label: job.statusLabel,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}