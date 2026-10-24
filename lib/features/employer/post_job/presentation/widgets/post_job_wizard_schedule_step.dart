import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/date_time_utils.dart';
import 'package:patch_bro/core/widgets/work_time_slot_grid.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/employer_job_post_selection_tile.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';

class PostJobWizardScheduleStep extends StatelessWidget {
  const PostJobWizardScheduleStep({
    super.key,
    required this.state,
    required this.onSelectDate,
    required this.onSlotToggled,
  });

  final PostJobState state;
  final VoidCallback onSelectDate;
  final ValueChanged<String> onSlotToggled;

  @override
  Widget build(BuildContext context) => PostJobSection(
        title: 'Schedule',
        subtitle: 'Choose a date and one or more two-hour work slots.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Date',
              value: DateTimeUtils.formatDate(state.selectedDate),
              onTap: onSelectDate,
            ),
            const SizedBox(height: 16),
            WorkTimeSlotGrid(
              selectedSlotIds: state.selectedSlotIds.toSet(),
              onSlotToggled: onSlotToggled,
              color: AppColors.employerPrimary,
            ),
            const SizedBox(height: 12),
            Text(
              '${state.selectedSlotIds.length} time slot${state.selectedSlotIds.length == 1 ? '' : 's'} selected'
              '${state.selectedSlotIds.isNotEmpty ? ' · ${state.selectedSlotIds.length * 2} working hours' : ''}'
              ' (lunch break is 12–1 PM)',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}
