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
import '../widgets/employer_workers_filter_sheet.dart';

class EmployerWorkersPage extends ConsumerStatefulWidget {
  const EmployerWorkersPage({super.key});

  @override
  ConsumerState<EmployerWorkersPage> createState() =>
      _EmployerWorkersPageState();
}

class _EmployerWorkersPageState
    extends ConsumerState<EmployerWorkersPage> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(employerWorkersControllerProvider.notifier)
          .loadWorkers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilter() async {
    final currentFilters =
        ref.read(employerWorkersControllerProvider).filters;

    final result = await showModalBottomSheet<EmployerWorkersFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: EmployerWorkersFilterSheet(
            initialFilters: currentFilters,
          ),
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    final controller =
        ref.read(employerWorkersControllerProvider.notifier);

    controller.updateFilters(result);

    controller.selectCategory(result.category);
  }

  void _openWorkerDetails(String workerId) {
    context.pushNamed(
      RouteNames.workerProfile,
      extra: workerId,
    );
  }

  Future<void> _toggleFavourite(String workerId) async {
    try {
      await ref
          .read(employerWorkersControllerProvider.notifier)
          .toggleFavourite(workerId);
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

  Future<void> _refresh() async {
    try {
      await ref
          .read(employerWorkersControllerProvider.notifier)
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerWorkersControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(EmployerWorkersState state) {
    if (state.isLoading && !state.hasWorkers) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.employerPrimary,
        ),
      );
    }

    if (state.isFailure && !state.hasWorkers) {
      return AppErrorView(
        title: 'Unable to load Workers',
        message:
            state.errorMessage ??
            'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: () {
          ref
              .read(employerWorkersControllerProvider.notifier)
              .loadWorkers();
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _WorkersHeader(
            onNotificationTap: () {
              context.pushNamed(RouteNames.employerNotifications);
            },
          ),
          const SizedBox(height: 16),
          _WorkersSearchBar(
            controller: _searchController,
            onChanged: ref
                .read(employerWorkersControllerProvider.notifier)
                .updateSearchQuery,
            onFilterTap: _openFilter,
            filterCount: state.activeFilterCount,
          ),
          const SizedBox(height: 14),
          _WorkersTabs(
            selectedTab: state.selectedTab,
            onChanged: ref
                .read(employerWorkersControllerProvider.notifier)
                .selectTab,
          ),
          const SizedBox(height: 12),
          EmployerWorkersCategoryChips(
            selectedCategory: state.selectedCategory,
            onSelected: (category) {
              ref
                  .read(
                    employerWorkersControllerProvider.notifier,
                  )
                  .selectCategory(category);
            },
          ),
          const SizedBox(height: 16),
          if (state.visibleWorkers.isEmpty)
            const _EmptyWorkers()
          else
            ...state.visibleWorkers.map(
              (worker) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EmployerWorkerCard(
                  key: ValueKey(worker.id),
                  worker: worker,
                  isToggling: worker.id == state.togglingWorkerId,
                  onTap: () => _openWorkerDetails(worker.id),
                  onToggleFavourite: () =>
                      _toggleFavourite(worker.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkersHeader extends StatelessWidget {
  const _WorkersHeader({
    required this.onNotificationTap,
  });

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workers',
                style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
              ),
              const SizedBox(height: 2),
              Text(
                'Find skilled professionals for your job',
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _WorkersSearchBar extends StatelessWidget {
  const _WorkersSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.filterCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final int filterCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search workers, skills or services...',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(
                    color: AppColors.employerPrimary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.employerPrimary,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(13),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            if (filterCount > 0)
              Positioned(
                right: -2,
                top: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$filterCount',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WorkersTabs extends StatelessWidget {
  const _WorkersTabs({
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
              selected:
                  selectedTab == EmployerWorkersTab.workers,
              onTap: () => onChanged(
                EmployerWorkersTab.workers,
              ),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Favourite Workers',
              selected:
                  selectedTab == EmployerWorkersTab.favourites,
              onTap: () => onChanged(
                EmployerWorkersTab.favourites,
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? AppColors.employerPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    selected
                        ? AppColors.white
                        : AppColors.textPrimary,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _EmptyWorkers extends StatelessWidget {
  const _EmptyWorkers();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 54,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'No workers found',
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing your search or filters.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}