import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:patch_bro/features/employer/workers/domain/repository/employer_workers_repository.dart';

import '../providers/employer_workers_providers.dart';
import 'employer_workers_state.dart';

class EmployerWorkersController extends Notifier<EmployerWorkersState> {
  EmployerWorkersRepository get _repository {
    return ref.read(employerWorkersRepositoryProvider);
  }

  @override
  EmployerWorkersState build() {
    return const EmployerWorkersState();
  }

  // ============================================================
  // LOAD WORKERS
  // ============================================================

  Future<void> loadWorkers() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      status: EmployerWorkersStatus.loading,
      clearError: true,
    );

    try {
      final workers = await _repository.getWorkers();

      state = state.copyWith(
        status: EmployerWorkersStatus.success,
        workers: List.unmodifiable(workers),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerWorkersStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  // ============================================================
  // REFRESH WORKERS
  // ============================================================

  Future<void> refreshWorkers() async {
    try {
      final workers = await _repository.getWorkers();

      state = state.copyWith(
        status: EmployerWorkersStatus.success,
        workers: List.unmodifiable(workers),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: state.hasWorkers
            ? EmployerWorkersStatus.success
            : EmployerWorkersStatus.failure,
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }

  // ============================================================
  // TAB
  // ============================================================

  void selectTab(EmployerWorkersTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void updateSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void selectCategory(String category) {
    state = state.copyWith(
      selectedCategory: category,
      filters: state.filters.copyWith(category: category),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  void updateFilters(EmployerWorkersFilters filters) {
    state = state.copyWith(
      filters: filters,
      selectedCategory: filters.category,
    );
  }

  void resetFilters() {
    state = state.copyWith(
      selectedCategory: 'All',
      filters: const EmployerWorkersFilters(),
    );
  }

  // ============================================================
  // FAVOURITE
  // ============================================================

  Future<void> toggleFavourite(String workerId) async {
    if (state.togglingWorkerId != null) {
      return;
    }

    final workerIndex = state.workers.indexWhere(
      (worker) => worker.id == workerId,
    );

    if (workerIndex == -1) {
      return;
    }

    final worker = state.workers[workerIndex];

    state = state.copyWith(togglingWorkerId: workerId, clearError: true);

    try {
      await _repository.toggleFavourite(workerId);

      final updatedWorker = worker.copyWith(isFavourite: !worker.isFavourite);

      final updatedWorkers = [...state.workers];

      updatedWorkers[workerIndex] = updatedWorker;

      state = state.copyWith(
        workers: List.unmodifiable(updatedWorkers),
        clearTogglingWorker: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        clearTogglingWorker: true,
      );

      rethrow;
    }
  }

  // ============================================================
  // FIND WORKER
  // ============================================================

  EmployerWorkerEntity? workerById(String id) {
    for (final worker in state.workers) {
      if (worker.id == id) {
        return worker;
      }
    }

    return null;
  }
}
