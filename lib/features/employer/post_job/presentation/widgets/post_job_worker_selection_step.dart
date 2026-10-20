import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/no_eligible_workers_widget.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/providers/employer_workers_providers.dart';

import 'post_job_worker_card_stack.dart';

class PostJobWorkerSelectionStep extends ConsumerStatefulWidget {
  const PostJobWorkerSelectionStep({super.key});

  @override
  ConsumerState<PostJobWorkerSelectionStep> createState() => _PostJobWorkerSelectionStepState();
}

class _PostJobWorkerSelectionStepState extends ConsumerState<PostJobWorkerSelectionStep> {
  late final TextEditingController _searchController;
  bool _showAllWorkers = false;
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
        unawaited(ref.read(employerWorkersControllerProvider.notifier).loadWorkers());
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
      if (previous?.category != next.category || previous?.skill != next.skill) {
        _scheduleReconciliation();
      }
    });
    ref.listen<EmployerWorkersState>(employerWorkersControllerProvider, (previous, next) {
      if (previous?.status != next.status && next.status == EmployerWorkersStatus.success) {
        _scheduleReconciliation();
      }
    });

    final jobState = ref.watch(postJobControllerProvider);
    final workerState = ref.watch(employerWorkersControllerProvider);
    final eligibleWorkers = _matchingWorkers(
      workerState.workers,
      category: jobState.category,
      skill: jobState.skill,
    );
    final eligibleWorkerIds = eligibleWorkers.map((worker) => worker.id).toSet();
    final sourceWorkers = _showAllWorkers ? workerState.workers : eligibleWorkers;
    final displayedWorkers = sourceWorkers
        .where((worker) => worker.name.toLowerCase().contains(_searchQuery))
        .toList(growable: false);
    final activeIndex = displayedWorkers.isEmpty
        ? 0
        : jobState.activeWorkerCardIndex.clamp(0, displayedWorkers.length - 1).toInt();
    final cardStackHeight = (MediaQuery.sizeOf(context).height * 0.54).clamp(350.0, 490.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Workers',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose up to 5 workers for your job',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.employerLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${jobState.selectedWorkerIds.length} of 5 workers selected',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.employerDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selected workers will receive an invitation after you post the job.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (workerState.isLoading || workerState.status == EmployerWorkersStatus.initial)
          SizedBox(
            height: cardStackHeight,
            child: const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary)),
          )
        else if (workerState.isFailure)
          _WorkerLoadError(
            message: workerState.errorMessage ?? 'Unable to load workers.',
            onRetry: _retryLoadingWorkers,
          )
        else ...[
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search workers by name',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.employerPrimary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAllWorkers = !_showAllWorkers),
              icon: Icon(_showAllWorkers ? Icons.filter_alt_rounded : Icons.people_outline_rounded),
              label: Text(_showAllWorkers ? 'Show Eligible Workers' : 'Show All Workers'),
            ),
          ),
          const SizedBox(height: 8),
          if (displayedWorkers.isEmpty)
            SizedBox(
              height: cardStackHeight,
              child: Center(
                child: _searchQuery.isNotEmpty
                    ? const _NoWorkersFoundForSearch()
                    : _showAllWorkers
                    ? const _NoWorkersAvailable()
                    : NoEligibleWorkersWidget(),
              ),
            )
          else
            PostJobWorkerCardStack(
              workers: displayedWorkers,
              activeIndex: activeIndex,
              selectedWorkerIds: jobState.selectedWorkerIds.toSet(),
              eligibleWorkerIds: eligibleWorkerIds,
              height: cardStackHeight.toDouble(),
              onIndexChanged: ref.read(postJobControllerProvider.notifier).setActiveWorkerCardIndex,
              onToggleSelected: _toggleWorker,
              onMoreDetails: (worker) {
                context.pushNamed(RouteNames.employerWorkerProfile, extra: worker.id);
              },
            ),
        ],
      ],
    );
  }

  List<EmployerWorkerEntity> _matchingWorkers(
    List<EmployerWorkerEntity> workers, {
    required String category,
    required String skill,
  }) {
    final normalizedCategory = category.trim().toLowerCase();
    final normalizedSkill = skill.trim().toLowerCase();
    if (normalizedCategory.isEmpty || normalizedSkill.isEmpty) return const [];

    return workers
        .where((worker) {
          final matchesCategory = worker.profession.trim().toLowerCase() == normalizedCategory;
          final matchesSkill = worker.skills.any(
            (workerSkill) => workerSkill.trim().toLowerCase() == normalizedSkill,
          );
          return matchesCategory &&
              matchesSkill &&
              (worker.isAvailableToday || worker.availableTomorrow);
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
      skill: jobState.skill,
    );
    final eligibleIds = eligibleWorkers.map((worker) => worker.id).toSet();
    ref.read(postJobControllerProvider.notifier).reconcileSelectedWorkers(eligibleIds);

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
    final changed = ref.read(postJobControllerProvider.notifier).toggleSelectedWorker(workerId);
    if (!changed && mounted) {
      AppSnackbar.error(context, 'You can select up to 5 workers.');
    }
  }

  Future<void> _retryLoadingWorkers() async {
    try {
      await ref.read(employerWorkersControllerProvider.notifier).refreshWorkers();
    } catch (error) {
      if (mounted) AppSnackbar.error(context, error.toString());
    }
  }
}

class _WorkerLoadError extends StatelessWidget {
  const _WorkerLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 350,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 38, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

class _NoWorkersFoundForSearch extends StatelessWidget {
  const _NoWorkersFoundForSearch();

  @override
  Widget build(BuildContext context) => const _EmptyWorkerSearchMessage(
    title: 'No workers found',
    message: 'Try a different name.',
  );
}

class _NoWorkersAvailable extends StatelessWidget {
  const _NoWorkersAvailable();

  @override
  Widget build(BuildContext context) => const _EmptyWorkerSearchMessage(
    title: 'No workers available',
    message: 'There are no workers to display right now.',
  );
}

class _EmptyWorkerSearchMessage extends StatelessWidget {
  const _EmptyWorkerSearchMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(message, textAlign: TextAlign.center),
    ],
  );
}
