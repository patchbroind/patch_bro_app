
import 'package:material_ui/material_ui.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

import '../controllers/worker_jobs_state.dart';

class WorkerJobsTabBar extends StatelessWidget {
  const WorkerJobsTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final WorkerJobsTab selectedTab;
  final ValueChanged<WorkerJobsTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: WorkerColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WorkerColors.border,
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Upcoming',
            tab: WorkerJobsTab.upcoming,
          ),
          _buildTab(
            label: 'Completed',
            tab: WorkerJobsTab.completed,
          ),
          _buildTab(
            label: 'Cancelled',
            tab: WorkerJobsTab.cancelled,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required WorkerJobsTab tab,
  }) {
    final isSelected = selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? WorkerColors.homePrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : WorkerColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected
                  ? FontWeight.w700
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}