
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/features/worker/home/domain/repository/worker_home_repository.dart';
import 'package:patch_bro/features/worker/home/presentation/providers/worker_home_providers.dart';

import 'worker_jobs_state.dart';

class WorkerJobsController extends Notifier<WorkerJobsState> {
  late final WorkerHomeRepository _repository;

  @override
  WorkerJobsState build() {
    _repository = ref.read(workerHomeRepositoryProvider);

    return const WorkerJobsState();
  }

  Future<void> loadJobs() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final jobs = await _repository.getAssignedJobs();

      state = state.copyWith(
        isLoading: false,
        jobs: List.unmodifiable(jobs),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshJobs() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final jobs = await _repository.getAssignedJobs();

      state = state.copyWith(
        isLoading: false,
        jobs: List.unmodifiable(jobs),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }

  void selectTab(WorkerJobsTab tab) {
    if (state.selectedTab == tab) return;

    state = state.copyWith(
      selectedTab: tab,
    );
  }
}