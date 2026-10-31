import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/worker_home_repository.dart';
import '../providers/worker_home_providers.dart';
import 'worker_home_state.dart';

class WorkerHomeController extends Notifier<WorkerHomeState> {
  late final WorkerHomeRepository _repository;

  @override
  WorkerHomeState build() {
    _repository = ref.read(workerHomeRepositoryProvider);
    return const WorkerHomeState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final jobs = await _repository.getAssignedJobs();
      state = state.copyWith(
        isLoading: false,
        jobs: List.unmodifiable(jobs),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
