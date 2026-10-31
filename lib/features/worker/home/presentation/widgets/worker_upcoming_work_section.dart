import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_empty_state.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: WorkerColors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: WorkerColors.homePrimaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: WorkerColors.homePrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Upcoming Works',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(color: WorkerColors.homePrimary),
                  ),
                ),
              ],
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  color: WorkerColors.homePrimary,
                ),
              )
            else if (errorMessage != null)
              const AppEmptyState(
                layout: AppEmptyStateLayout.inline,
                message: 'Unable to load upcoming works.',
                icon: Icons.error_outline_rounded,
                padding: EdgeInsets.symmetric(vertical: 12),
                iconToContentSpacing: 10,
              )
            else if (jobs.isEmpty)
              const AppEmptyState(
                layout: AppEmptyStateLayout.inline,
                message: 'No upcoming work assigned yet.',
                icon: Icons.event_busy_rounded,
                padding: EdgeInsets.symmetric(vertical: 12),
                iconToContentSpacing: 10,
              )
            else
              ...jobs
                  .take(3)
                  .map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: WorkerWorkCard(job: job),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
