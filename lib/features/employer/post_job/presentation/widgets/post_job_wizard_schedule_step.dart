import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_schedule_fields.dart';

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
    child: PostJobScheduleFields(
      selectedDate: state.selectedDate,
      selectedSlotIds: state.selectedSlotIds.toSet(),
      onSelectDate: onSelectDate,
      onSlotToggled: onSlotToggled,
    ),
  );
}
