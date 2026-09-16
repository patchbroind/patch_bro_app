import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import '../controllers/employer_workers_state.dart';

class EmployerWorkersTabs extends StatelessWidget {
  const EmployerWorkersTabs({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  final EmployerWorkersTab selectedTab;
  final ValueChanged<EmployerWorkersTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Workers',
              selected: selectedTab == EmployerWorkersTab.workers,
              onTap: () {
                onChanged(
                  EmployerWorkersTab.workers,
                );
              },
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Favourite Workers',
              selected: selectedTab == EmployerWorkersTab.favourites,
              onTap: () {
                onChanged(
                  EmployerWorkersTab.favourites,
                );
              },
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.employerPrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected
                      ? AppColors.white
                      : AppColors.textPrimary,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}