
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_network_image.dart';
import 'package:patch_bro/features/worker/home/domain/entities/worker_home_job_entity.dart';
import 'package:patch_bro/features/worker/shared/presentation/widgets/worker_meta_line.dart';

class WorkerWorkCard extends StatelessWidget {
  const WorkerWorkCard({
    super.key,
    required this.job,
    this.onTap,
  });

  final WorkerHomeJobEntity job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateBadgeLabel(
      job.scheduledDate,
      job.status,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: WorkerColors.surfaceSecondary,
            border: Border.all(color: WorkerColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppNetworkImage(
                  imageUrl: job.imageUrl,
                  width: 74,
                  height: 74,
                  fit: BoxFit.cover,
                  backgroundColor: WorkerColors.imagePlaceholder,
                  fallback: const Icon(
                    Icons.work_outline_rounded,
                    color: WorkerColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    WorkerMetaLine(
                      icon: Icons.location_on_outlined,
                      text: job.locationAddress,
                    ),
                    const SizedBox(height: 4),
                    WorkerMetaLine(
                      icon: Icons.calendar_month_outlined,
                      text: DateFormat('EEE, d MMM')
                          .format(job.scheduledDate),
                    ),
                    const SizedBox(height: 4),
                    WorkerMetaLine(
                      icon: Icons.access_time_rounded,
                      text: job.scheduledTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: WorkerColors.homePrimaryLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        color: WorkerColors.homePrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: WorkerColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateBadgeLabel(DateTime scheduledDate, String status) {
    final normalizedStatus = status.trim().toLowerCase();

    if (normalizedStatus == 'completed') return 'Completed';

    if (normalizedStatus == 'cancelled' ||
        normalizedStatus == 'canceled') {
      return 'Cancelled';
    }

    if (normalizedStatus == 'expired') return 'Expired';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    final difference = jobDate.difference(today).inDays;

    if (difference < 0) return 'Expired';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';

    return DateFormat('d MMM').format(scheduledDate);
  }
}