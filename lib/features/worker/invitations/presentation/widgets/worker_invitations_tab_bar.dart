import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

enum WorkerInvitationTab {
  active,
  expired,
}

class WorkerInvitationsTabBar extends StatelessWidget {
  const WorkerInvitationsTabBar({
    super.key,
    required this.selectedTab,
    required this.activeCount,
    required this.expiredCount,
    required this.onChanged,
  });

  final WorkerInvitationTab selectedTab;
  final int activeCount;
  final int expiredCount;
  final ValueChanged<WorkerInvitationTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WorkerColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Active',
              count: activeCount,
              selected: selectedTab == WorkerInvitationTab.active,
              onTap: () => onChanged(WorkerInvitationTab.active),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Expired',
              count: expiredCount,
              selected: selectedTab == WorkerInvitationTab.expired,
              onTap: () => onChanged(WorkerInvitationTab.expired),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? WorkerColors.homePrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? WorkerColors.white
                      : WorkerColors.textPrimary,
                ),
              ),
              const SizedBox(width: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? WorkerColors.white
                      : WorkerColors.imagePlaceholder,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected
                        ? WorkerColors.homePrimary
                        : WorkerColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}