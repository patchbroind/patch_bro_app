import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_jobs_repository.dart';
import '../providers/employer_jobs_providers.dart';
import 'employer_jobs_state.dart';

class EmployerJobsController extends Notifier<EmployerJobsState> {
  EmployerJobsRepository get _repository {
    return ref.read(employerJobsRepositoryProvider);
  }

  @override
  EmployerJobsState build() {
    return const EmployerJobsState();
  }

  Future<void> loadJobs() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(status: EmployerJobsStatus.loading, clearError: true);

    try {
      final jobs = await _repository.getEmployerJobs();
      state = state.copyWith(
        status: EmployerJobsStatus.success,
        jobs: List.unmodifiable(jobs),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(status: EmployerJobsStatus.failure, errorMessage: error.toString());
    }
  }

  Future<void> refreshJobs() async {
    try {
      final jobs = await _repository.getEmployerJobs();
      state = state.copyWith(
        status: EmployerJobsStatus.success,
        jobs: List.unmodifiable(jobs),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: state.jobs.isEmpty ? EmployerJobsStatus.failure : EmployerJobsStatus.success,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  void selectFilter(EmployerJobsFilter filter) {
    if (state.filter == filter) {
      return;
    }

    state = state.copyWith(filter: filter);
  }
}
