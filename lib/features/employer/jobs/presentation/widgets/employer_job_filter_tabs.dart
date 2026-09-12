import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../controllers/employer_jobs_state.dart';

class EmployerJobFilterTabs extends StatelessWidget {
  const EmployerJobFilterTabs({super.key, required this.selectedFilter, required this.onSelected});

  final EmployerJobsFilter selectedFilter;
  final ValueChanged<EmployerJobsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterTab(
            label: 'All',
            filter: EmployerJobsFilter.all,
            selectedFilter: selectedFilter,
            onSelected: onSelected,
          ),
          _FilterTab(
            label: 'Active',
            filter: EmployerJobsFilter.active,
            selectedFilter: selectedFilter,
            onSelected: onSelected,
          ),
          _FilterTab(
            label: 'Completed',
            filter: EmployerJobsFilter.completed,
            selectedFilter: selectedFilter,
            onSelected: onSelected,
          ),
          _FilterTab(
            label: 'Cancelled',
            filter: EmployerJobsFilter.cancelled,
            selectedFilter: selectedFilter,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.filter,
    required this.selectedFilter,
    required this.onSelected,
  });

  final String label;
  final EmployerJobsFilter filter;
  final EmployerJobsFilter selectedFilter;
  final ValueChanged<EmployerJobsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = filter == selectedFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(filter),
        selectedColor: AppColors.info,
        backgroundColor: AppColors.imagePlaceholder,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        showCheckmark: false,
      ),
    );
  }
}
