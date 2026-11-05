import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_network_image.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/meta_line.dart';

class WorkerWorkCard extends StatelessWidget {
  const WorkerWorkCard({super.key, required this.job});

  final dynamic job;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _relativeDateLabel(job.scheduledDate as DateTime);
    return Container(
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
              imageUrl: job.imageUrl as String?,
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
                  job.title as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                MetaLine(
                  icon: Icons.location_on_outlined,
                  text: job.locationAddress as String,
                ),
                const SizedBox(height: 4),
                MetaLine(
                  icon: Icons.calendar_month_outlined,
                  text: DateFormat(
                    'EEE, d MMM',
                  ).format(job.scheduledDate as DateTime),
                ),
                const SizedBox(height: 4),
                MetaLine(
                  icon: Icons.access_time_rounded,
                  text: job.scheduledTime as String,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
    );
  }

  String _relativeDateLabel(DateTime scheduledDate) {
    final difference = scheduledDate.difference(DateTime.now());
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Tomorrow';
    if (difference.inDays < 7) return 'In ${difference.inDays} days';
    return DateFormat('d MMM').format(scheduledDate);
  }
}
