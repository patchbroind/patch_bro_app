import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_home_section.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_home_section_state.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_work_card.dart';

class WorkerUpcomingWorksSection extends StatelessWidget {
  const WorkerUpcomingWorksSection({
    super.key,
    required this.jobs,
    required this.isLoading,
    required this.errorMessage,
    required this.onViewAll,
  });

  final List<dynamic> jobs;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return WorkerHomeSection(
  title: 'Upcoming Works',
  icon: Icons.calendar_month_rounded,
  iconBackgroundColor: WorkerColors.homePrimaryLight,
  iconColor: WorkerColors.homePrimary,
  child: WorkerHomeSectionState(
    isLoading: isLoading,
    errorMessage: errorMessage,
    isEmpty: !isLoading && errorMessage == null && jobs.isEmpty,
    emptyMessage: 'No upcoming work assigned yet.',
    emptyIcon: Icons.event_busy_rounded,
    child: Column(
      children: jobs.take(3).map((job) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: WorkerWorkCard(job: job),
        );
      }).toList(),
    ),
  ),
);
  }
}
