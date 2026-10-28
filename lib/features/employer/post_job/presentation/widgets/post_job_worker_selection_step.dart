import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/scheduling/work_time_slot.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_empty_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_selected_workers_count.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_load_error.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_search_bar.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_selection_time_slot.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/providers/employer_workers_providers.dart';

import 'post_job_worker_card_stack.dart';

class PostJobWorkerSelectionStep extends ConsumerStatefulWidget {
  const PostJobWorkerSelectionStep({super.key});

  @override
  ConsumerState<PostJobWorkerSelectionStep> createState() =>
      _PostJobWorkerSelectionStepState();
}

class _PostJobWorkerSelectionStepState
    extends ConsumerState<PostJobWorkerSelectionStep> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final workerState = ref.read(employerWorkersControllerProvider);
      if (workerState.status == EmployerWorkersStatus.initial) {
        unawaited(
          ref.read(employerWorkersControllerProvider.notifier).loadWorkers(),
        );
      } else {
        _reconcileSelection();
      }
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PostJobState>(postJobControllerProvider, (previous, next) {
      if (previous?.category != next.category ||
          previous?.selectedDate != next.selectedDate ||
          previous?.selectedSlotIds.join(',') !=
              next.selectedSlotIds.join(',')) {
        _scheduleReconciliation();
      }
    });
    ref.listen<EmployerWorkersState>(employerWorkersControllerProvider, (
      previous,
      next,
    ) {
      if (previous?.status != next.status &&
          next.status == EmployerWorkersStatus.success) {
        _scheduleReconciliation();
      }
    });

    final jobState = ref.watch(postJobControllerProvider);
    final workerState = ref.watch(employerWorkersControllerProvider);
    final eligibleWorkers = _matchingWorkers(
      workerState.workers,
      category: jobState.category,
      date: jobState.selectedDate,
      slotIds: jobState.selectedSlotIds,
    );
    final eligibleWorkerIds = eligibleWorkers
        .map((worker) => worker.id)
        .toSet();
    final displayedWorkers = eligibleWorkers
        .where((worker) => worker.name.toLowerCase().contains(_searchQuery))
        .toList(growable: false);
    final activeIndex = displayedWorkers.isEmpty
        ? 0
        : jobState.activeWorkerCardIndex
              .clamp(0, displayedWorkers.length - 1)
              .toInt();
    final cardStackHeight = (MediaQuery.sizeOf(context).height * 0.54).clamp(
      350.0,
      490.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Workers',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            PostJobSelectedWorkersCount(jobState: jobState),
          ],
        ),
        // const SizedBox(height: 6),
        // Text(
        //   'Choose up to 5 workers for your job',
        //   style: Theme.of(
        //     context,
        //   ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        // ),
        // const SizedBox(height: 14),

        const SizedBox(height: 8),
        Text(
          'Selected workers will receive an invitation after you post the job.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (workerState.isLoading ||
            workerState.status == EmployerWorkersStatus.initial)
          SizedBox(
            height: cardStackHeight,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.employerPrimary,
              ),
            ),
          )
        else if (workerState.isFailure)
          PostJobWorkerLoadError(
            message: workerState.errorMessage ?? 'Unable to load workers.',
            onRetry: _retryLoadingWorkers,
          )
        else ...[
          PostJobWorkerSearchbar(
            searchController: _searchController,
            searchQuery: _searchQuery,
          ),
          const SizedBox(height: 6),
          PostJobWorkerSelectionTimeSlot(jobState: jobState),
          const SizedBox(height: 8),
          if (displayedWorkers.isEmpty)
            SizedBox(
              height: cardStackHeight,
              child: Center(
                child: _searchQuery.isNotEmpty
                    ? const _NoWorkersFoundForSearch()
                    : const _NoWorkersAvailable(),
              ),
            )
          else
            PostJobWorkerCardStack(
              workers: displayedWorkers,
              activeIndex: activeIndex,
              selectedWorkerIds: jobState.selectedWorkerIds.toSet(),
              eligibleWorkerIds: eligibleWorkerIds,
              allowIneligibleSelection: false,
              height: cardStackHeight.toDouble(),
              onIndexChanged: ref
                  .read(postJobControllerProvider.notifier)
                  .setActiveWorkerCardIndex,
              onToggleSelected: _toggleWorker,
              onMoreDetails: (worker) {
                context.pushNamed(
                  RouteNames.employerWorkerProfile,
                  extra: worker.id,
                );
              },
            ),
        ],
      ],
    );
  }

  List<EmployerWorkerEntity> _matchingWorkers(
    List<EmployerWorkerEntity> workers, {
    required String category,
    required DateTime? date,
    required List<String> slotIds,
  }) {
    final normalizedCategory = category.trim().toLowerCase();
    if (normalizedCategory.isEmpty || date == null || slotIds.isEmpty) {
      return const [];
    }
    final dateSchedule = formatScheduleDate(date);

    return workers
        .where((worker) {
          final matchesCategory =
              worker.profession.trim().toLowerCase() == normalizedCategory;
          final availability =
              worker.availabilitySchedule[dateSchedule] ?? const {};
          return matchesCategory &&
              slotIds.every((slotId) => availability[slotId] == 'available');
        })
        .toList(growable: false);
  }

  void _reconcileSelection() {
    final workerState = ref.read(employerWorkersControllerProvider);
    if (workerState.status != EmployerWorkersStatus.success) return;

    final jobState = ref.read(postJobControllerProvider);
    final eligibleWorkers = _matchingWorkers(
      workerState.workers,
      category: jobState.category,
      date: jobState.selectedDate,
      slotIds: jobState.selectedSlotIds,
    );
    final eligibleIds = eligibleWorkers.map((worker) => worker.id).toSet();
    ref
        .read(postJobControllerProvider.notifier)
        .reconcileSelectedWorkers(eligibleIds);

    if (eligibleWorkers.isNotEmpty) {
      if (jobState.activeWorkerCardIndex >= eligibleWorkers.length) {
        ref
            .read(postJobControllerProvider.notifier)
            .setActiveWorkerCardIndex(eligibleWorkers.length - 1);
      }
    } else if (jobState.activeWorkerCardIndex != 0) {
      ref.read(postJobControllerProvider.notifier).setActiveWorkerCardIndex(0);
    }
  }

  void _scheduleReconciliation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reconcileSelection();
    });
  }

  void _toggleWorker(String workerId) {
    final changed = ref
        .read(postJobControllerProvider.notifier)
        .toggleSelectedWorker(workerId);
    if (!changed && mounted) {
      AppSnackbar.error(context, 'You can select up to 5 workers.');
    }
  }

  Future<void> _retryLoadingWorkers() async {
    try {
      await ref
          .read(employerWorkersControllerProvider.notifier)
          .refreshWorkers();
    } catch (error) {
      if (mounted) AppSnackbar.error(context, error.toString());
    }
  }
}

class _NoWorkersFoundForSearch extends StatelessWidget {
  const _NoWorkersFoundForSearch();

  @override
  Widget build(BuildContext context) => const AppEmptyState(
    title: 'No workers found',
    message: 'Try a different name.',
    messageColor: null,
    titleToMessageSpacing: 4,
  );
}

class _NoWorkersAvailable extends StatelessWidget {
  const _NoWorkersAvailable();

  @override
  Widget build(BuildContext context) => const AppEmptyState(
    title: 'No available workers',
    message:
        'Try another date or time slot. Workers must match the category and be available for every selected slot.',
    messageColor: null,
    titleToMessageSpacing: 4,
  );
}
