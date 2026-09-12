import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_favourite_workers_repository.dart';
import '../providers/employer_favourite_workers_providers.dart';
import 'employer_favourite_workers_state.dart';

class EmployerFavouriteWorkersController extends Notifier<EmployerFavouriteWorkersState> {
  EmployerFavouriteWorkersRepository get _repository {
    return ref.read(employerFavouriteWorkersRepositoryProvider);
  }

  @override
  EmployerFavouriteWorkersState build() {
    return const EmployerFavouriteWorkersState();
  }

  Future<void> loadFavouriteWorkers() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(status: EmployerFavouriteWorkersStatus.loading, clearError: true);

    try {
      final workers = await _repository.getFavouriteWorkers();
      state = state.copyWith(
        status: EmployerFavouriteWorkersStatus.success,
        favouriteWorkers: List.unmodifiable(workers),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerFavouriteWorkersStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshFavouriteWorkers() async {
    try {
      final workers = await _repository.getFavouriteWorkers();
      state = state.copyWith(
        status: EmployerFavouriteWorkersStatus.success,
        favouriteWorkers: List.unmodifiable(workers),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: state.hasWorkers
            ? EmployerFavouriteWorkersStatus.success
            : EmployerFavouriteWorkersStatus.failure,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> toggleFavourite(String workerId) async {
    if (state.togglingWorkerId != null) {
      return;
    }

    state = state.copyWith(togglingWorkerId: workerId);

    try {
      await _repository.toggleFavourite(workerId);
      final workers = state.favouriteWorkers
          .where((worker) => worker.id != workerId)
          .toList(growable: false);
      state = state.copyWith(
        favouriteWorkers: workers,
        clearTogglingWorker: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString(), clearTogglingWorker: true);
      rethrow;
    }
  }
}
