
import 'package:material_ui/material_ui.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

import '../controllers/worker_jobs_state.dart';

class WorkerJobsEmptyState extends StatelessWidget {
  const WorkerJobsEmptyState({
    super.key,
    required this.tab,
  });

  final WorkerJobsTab tab;

  String get _title {
    switch (tab) {
      case WorkerJobsTab.upcoming:
        return 'No Upcoming Works';

      case WorkerJobsTab.completed:
        return 'No Completed Works';

      case WorkerJobsTab.cancelled:
        return 'No Cancelled Works';
    }
  }

  String get _message {
    switch (tab) {
      case WorkerJobsTab.upcoming:
        return 'Your upcoming assigned works will appear here.';

      case WorkerJobsTab.completed:
        return 'You haven\'t completed any works yet.';

      case WorkerJobsTab.cancelled:
        return 'You don\'t have any cancelled works.';
    }
  }

  IconData get _icon {
    switch (tab) {
      case WorkerJobsTab.upcoming:
        return Icons.work_history_outlined;

      case WorkerJobsTab.completed:
        return Icons.task_alt_rounded;

      case WorkerJobsTab.cancelled:
        return Icons.event_busy_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: WorkerColors.homePrimaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                _icon,
                size: 36,
                color: WorkerColors.homePrimary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: WorkerColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WorkerColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}