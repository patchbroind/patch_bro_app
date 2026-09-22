import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_workers_category_chips.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_workers_header.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_workers_list.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_workers_search_bar.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_workers_tabs.dart';

class EmployerWorkersContent extends StatelessWidget {
  const EmployerWorkersContent({
    super.key,
    required this.state,
    required this.searchController,
    required this.onNotificationTap,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onTabChanged,
    required this.onCategorySelected,
    required this.onWorkerTap,
    required this.onFavouriteTap,
    required this.onRefresh,
    required this.onRetry,
    this.onInviteTap,
    this.showInviteButton = false,
    this.invitingWorkerId,
    this.invitedWorkerIds = const {},
  });

  final EmployerWorkersState state;

  final TextEditingController searchController;

  final VoidCallback onNotificationTap;

  final ValueChanged<String> onSearchChanged;

  final VoidCallback onFilterTap;

  final ValueChanged<EmployerWorkersTab> onTabChanged;

  final ValueChanged<String> onCategorySelected;

  final ValueChanged<String> onWorkerTap;

  final ValueChanged<String> onFavouriteTap;

  final Future<void> Function() onRefresh;

  final VoidCallback onRetry;

  final ValueChanged<String>? onInviteTap;

  final bool showInviteButton;

  final String? invitingWorkerId;

  final Set<String> invitedWorkerIds;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasWorkers) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasWorkers) {
      return AppErrorView(
        title: 'Unable to load Workers',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          EmployerWorkersHeader(onNotificationTap: onNotificationTap),
          const SizedBox(height: 16),
          EmployerWorkersSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onFilterTap: onFilterTap,
            filterCount: state.activeFilterCount,
          ),
          const SizedBox(height: 14),
          EmployerWorkersTabs(selectedTab: state.selectedTab, onChanged: onTabChanged),
          const SizedBox(height: 12),
          EmployerWorkersCategoryChips(
            selectedCategory: state.selectedCategory,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: 16),
          EmployerWorkerList(
            state: state,
            onWorkerTap: onWorkerTap,
            onFavouriteTap: onFavouriteTap,
            onInviteTap: onInviteTap,
            showInviteButton: showInviteButton,
            invitingWorkerId: invitingWorkerId,
            invitedWorkerIds: invitedWorkerIds,
          ),
        ],
      ),
    );
  }
}
