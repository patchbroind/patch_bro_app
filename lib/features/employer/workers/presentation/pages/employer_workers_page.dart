import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import '../controllers/employer_workers_state.dart';
import '../providers/employer_workers_providers.dart';
import '../widgets/employer_worker_card.dart';
import '../widgets/employer_workers_category_chips.dart';
import '../widgets/employer_workers_empty_state.dart';
import '../widgets/employer_workers_filter_sheet.dart';
import '../widgets/employer_workers_header.dart';
import '../widgets/employer_workers_search_bar.dart';
import '../widgets/employer_workers_tabs.dart';

class EmployerWorkersPage
    extends ConsumerStatefulWidget {
  const EmployerWorkersPage({
    super.key,
  });

  @override
  ConsumerState<EmployerWorkersPage>
      createState() =>
          _EmployerWorkersPageState();
}

class _EmployerWorkersPageState
    extends ConsumerState<EmployerWorkersPage> {
  late final TextEditingController
      _searchController;

  bool _jobFilterApplied = false;

  @override
  void initState() {
    super.initState();

    _searchController =
        TextEditingController();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(
            employerWorkersControllerProvider
                .notifier,
          )
          .loadWorkers();

      _applyJobFilterFromRoute();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // JOB FILTER
  // ============================================================

  void _applyJobFilterFromRoute() {
    if (_jobFilterApplied) {
      return;
    }

    final uri =
        GoRouterState.of(context).uri;

    final category =
        uri.queryParameters['category']
            ?.trim();

    final skill =
        uri.queryParameters['skill']
            ?.trim();

    if ((category == null ||
            category.isEmpty) &&
        (skill == null ||
            skill.isEmpty)) {
      return;
    }

    ref
        .read(
          employerWorkersControllerProvider
              .notifier,
        )
        .applyJobFilters(
          category: category ?? 'All',
          skill: skill ?? '',
        );

    if (skill != null &&
        skill.isNotEmpty) {
      _searchController.text =
          skill;
    }

    _jobFilterApplied = true;
  }

  // ============================================================
  // FILTER
  // ============================================================

  Future<void> _openFilter() async {
    final currentFilters =
        ref
            .read(
              employerWorkersControllerProvider,
            )
            .filters;

    final result =
        await showModalBottomSheet<
            EmployerWorkersFilters>(
      context: context,
      isScrollControlled:
          true,
      useSafeArea: true,
      backgroundColor:
          Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child:
              EmployerWorkersFilterSheet(
            initialFilters:
                currentFilters,
          ),
        );
      },
    );

    if (result == null ||
        !mounted) {
      return;
    }

    ref
        .read(
          employerWorkersControllerProvider
              .notifier,
        )
        .updateFilters(
          result,
        );
  }

  // ============================================================
  // WORKER DETAILS
  // ============================================================

  void _openWorkerDetails(
    String workerId,
  ) {
    context.pushNamed(
      RouteNames.employerWorkerProfile,
      extra: workerId,
    );
  }

  // ============================================================
  // FAVOURITE
  // ============================================================

  Future<void> _toggleFavourite(
    String workerId,
  ) async {
    try {
      await ref
          .read(
            employerWorkersControllerProvider
                .notifier,
          )
          .toggleFavourite(
            workerId,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to update favourite worker. Please try again.',
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    try {
      await ref
          .read(
            employerWorkersControllerProvider
                .notifier,
          )
          .refreshWorkers();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to refresh workers. Please try again.',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final state =
        ref.watch(
      employerWorkersControllerProvider,
    );

    return Scaffold(
      body: SafeArea(
        child:
            _WorkersContent(
          state: state,
          searchController:
              _searchController,
          onNotificationTap:
              _openNotifications,
          onSearchChanged:
              _updateSearch,
          onFilterTap:
              _openFilter,
          onTabChanged:
              _selectTab,
          onCategorySelected:
              _selectCategory,
          onWorkerTap:
              _openWorkerDetails,
          onFavouriteTap:
              _toggleFavourite,
          onRefresh:
              _refresh,
          onRetry:
              _loadWorkers,
        ),
      ),
    );
  }

  // ============================================================
  // CALLBACKS
  // ============================================================

  void _openNotifications() {
    context.pushNamed(
      RouteNames.employerNotifications,
    );
  }

  void _updateSearch(
    String value,
  ) {
    ref
        .read(
          employerWorkersControllerProvider
              .notifier,
        )
        .updateSearchQuery(
          value,
        );
  }

  void _selectTab(
    EmployerWorkersTab tab,
  ) {
    ref
        .read(
          employerWorkersControllerProvider
              .notifier,
        )
        .selectTab(
          tab,
        );
  }

  void _selectCategory(
    String category,
  ) {
    ref
        .read(
          employerWorkersControllerProvider
              .notifier,
        )
        .selectCategory(
          category,
        );
  }

  void _loadWorkers() {
    ref
        .read(
          employerWorkersControllerProvider
              .notifier,
        )
        .loadWorkers();
  }
}

// ============================================================================
// WORKERS CONTENT
// ============================================================================

class _WorkersContent
    extends StatelessWidget {
  const _WorkersContent({
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
  });

  final EmployerWorkersState state;
  final TextEditingController
      searchController;

  final VoidCallback
      onNotificationTap;

  final ValueChanged<String>
      onSearchChanged;

  final VoidCallback onFilterTap;

  final ValueChanged<
      EmployerWorkersTab>
      onTabChanged;

  final ValueChanged<String>
      onCategorySelected;

  final ValueChanged<String>
      onWorkerTap;

  final ValueChanged<String>
      onFavouriteTap;

  final Future<void> Function()
      onRefresh;

  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (state.isLoading &&
        !state.hasWorkers) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              AppColors.employerPrimary,
        ),
      );
    }

    if (state.isFailure &&
        !state.hasWorkers) {
      return AppErrorView(
        title:
            'Unable to load Workers',
        message:
            state.errorMessage ??
                'Please check your connection and try again.',
        icon:
            Icons.cloud_off_outlined,
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      color:
          AppColors.employerPrimary,
      onRefresh: onRefresh,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          28,
        ),
        children: [
          EmployerWorkersHeader(
            onNotificationTap:
                onNotificationTap,
          ),
          const SizedBox(
            height: 16,
          ),
          EmployerWorkersSearchBar(
            controller:
                searchController,
            onChanged:
                onSearchChanged,
            onFilterTap:
                onFilterTap,
            filterCount:
                state.activeFilterCount,
          ),
          const SizedBox(
            height: 14,
          ),
          EmployerWorkersTabs(
            selectedTab:
                state.selectedTab,
            onChanged:
                onTabChanged,
          ),
          const SizedBox(
            height: 12,
          ),
          EmployerWorkersCategoryChips(
            selectedCategory:
                state.selectedCategory,
            onSelected:
                onCategorySelected,
          ),
          const SizedBox(
            height: 16,
          ),
          _WorkerList(
            state: state,
            onWorkerTap:
                onWorkerTap,
            onFavouriteTap:
                onFavouriteTap,
          ),
        ],
      ),
    );
  }
}

class _WorkerList
    extends StatelessWidget {
  const _WorkerList({
    required this.state,
    required this.onWorkerTap,
    required this.onFavouriteTap,
  });

  final EmployerWorkersState state;

  final ValueChanged<String>
      onWorkerTap;

  final ValueChanged<String>
      onFavouriteTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final workers =
        state.visibleWorkers;

    if (workers.isEmpty) {
      return EmployerWorkersEmptyState(
        // selectedTab:
        //     state.selectedTab,
        // hasSearch:
        //     state.searchQuery
        //         .trim()
        //         .isNotEmpty,
        // hasFilters:
        //     state.activeFilterCount >
        //         0,
      );
    }

    return Column(
      children: [
        for (final worker in workers)
          Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child:
                EmployerWorkerCard(
              worker: worker,
              onTap: () =>
                  onWorkerTap(
                worker.id,
              ),
              onToggleFavourite:
                  () =>
                      onFavouriteTap(
                worker.id,
              ),
              isToggling:
                  state.togglingWorkerId ==
                      worker.id,
            ),
          ),
      ],
    );
  }
}