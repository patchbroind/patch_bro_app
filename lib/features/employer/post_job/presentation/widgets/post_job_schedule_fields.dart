import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/date_time_utils.dart';
import 'package:patch_bro/core/widgets/work_time_slot_grid.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/employer_job_post_selection_tile.dart';

class PostJobScheduleFields extends StatelessWidget {
  const PostJobScheduleFields({
    super.key,
    required this.selectedDate,
    required this.selectedSlotIds,
    required this.onSelectDate,
    required this.onSlotToggled,
  });

  final DateTime? selectedDate;
  final Set<String> selectedSlotIds;
  final VoidCallback onSelectDate;
  final ValueChanged<String> onSlotToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionTile(
          icon: Icons.calendar_today_outlined,
          title: 'Date',
          value: DateTimeUtils.formatDate(selectedDate),
          onTap: onSelectDate,
        ),
        const SizedBox(height: 16),
        WorkTimeSlotGrid(
          selectedSlotIds: selectedSlotIds,
          onSlotToggled: onSlotToggled,
          color: AppColors.employerPrimary,
        ),
        const SizedBox(height: 12),
        Text(
          '${selectedSlotIds.length} time slot${selectedSlotIds.length == 1 ? '' : 's'} selected'
          '${selectedSlotIds.isNotEmpty ? ' · ${selectedSlotIds.length * 2} working hours' : ''}'
          ' (lunch break is 12–1 PM)',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
