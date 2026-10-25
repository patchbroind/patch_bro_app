import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/scheduling/work_time_slot.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';

class PostJobWorkerSelectionTimeSlot extends ConsumerWidget {
  const PostJobWorkerSelectionTimeSlot({super.key, required this.jobState});

  final PostJobState jobState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context, ref),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              jobState.selectedDate == null
                  ? 'Choose date'
                  : MaterialLocalizations.of(context).formatMediumDate(jobState.selectedDate!),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PopupMenuButton<String>(
            tooltip: 'Change time slots',
            onSelected: ref.read(postJobControllerProvider.notifier).toggleTimeSlot,
            itemBuilder: (context) => WorkTimeSlot.values
                .map((slot) {
                  final selected = jobState.selectedSlotIds.contains(slot.id);
                  return PopupMenuItem<String>(
                    value: slot.id,
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.check_box : Icons.check_box_outline_blank,
                          color: selected ? AppColors.employerPrimary : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(slot.label)),
                      ],
                    ),
                  );
                })
                .toList(growable: false),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Change your slots',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(postJobControllerProvider.notifier);
    final current = ref.read(postJobControllerProvider).selectedDate;
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    var initialDate = current ?? firstDate;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    final selected = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2, now.month, now.day),
      initialDate: initialDate,
    );
    if (selected != null) controller.setDate(selected);
  }
}
