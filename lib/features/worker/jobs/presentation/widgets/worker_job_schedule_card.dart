
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'package:patch_bro/core/scheduling/work_time_slot.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/home/domain/entities/worker_home_job_entity.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';

class WorkerJobScheduleCard extends StatelessWidget {
  const WorkerJobScheduleCard({
    super.key,
    required this.job,
  });

  final WorkerHomeJobEntity job;

  @override
  Widget build(BuildContext context) {
    final selectedSlots = WorkTimeSlot.values
        .where((slot) => job.scheduledSlotIds.contains(slot.id))
        .toList();

    return WorkerJobDetailSection(
      title: 'Schedule',
      icon: Icons.calendar_month_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScheduleRow(
            icon: Icons.calendar_today_outlined,
            label: 'Job Date',
            value: DateFormat('EEEE, d MMMM yyyy')
                .format(job.scheduledDate),
          ),
          const SizedBox(height: 14),
          _ScheduleRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: job.scheduledTime,
          ),
          if (selectedSlots.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected Time Slots',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: WorkerColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSlots.map((slot) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: WorkerColors.homePrimaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: WorkerColors.homePrimary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: WorkerColors.homePrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slot.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: WorkerColors.homePrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: WorkerColors.homePrimary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WorkerColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WorkerColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}