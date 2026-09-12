import 'package:flutter/foundation.dart';

import '../../domain/entities/employer_job_entity.dart';

enum EmployerJobsStatus { initial, loading, success, failure }

enum EmployerJobsFilter { all, active, completed, cancelled }

@immutable
class EmployerJobsState {
  const EmployerJobsState({
    this.status = EmployerJobsStatus.initial,
    this.jobs = const [],
    this.filter = EmployerJobsFilter.all,
    this.errorMessage,
  });

  final EmployerJobsStatus status;
  final List<EmployerJobEntity> jobs;
  final EmployerJobsFilter filter;
  final String? errorMessage;

  bool get isLoading => status == EmployerJobsStatus.loading;
  bool get isSuccess => status == EmployerJobsStatus.success;
  bool get isFailure => status == EmployerJobsStatus.failure;
  bool get hasJobs => jobs.isNotEmpty;

  List<EmployerJobEntity> get filteredJobs {
    switch (filter) {
      case EmployerJobsFilter.all:
        return jobs;
      case EmployerJobsFilter.active:
        return jobs.where((job) => job.status == EmployerJobStatus.active).toList();
      case EmployerJobsFilter.completed:
        return jobs.where((job) => job.status == EmployerJobStatus.completed).toList();
      case EmployerJobsFilter.cancelled:
        return jobs.where((job) => job.status == EmployerJobStatus.cancelled).toList();
    }
  }

  EmployerJobsState copyWith({
    EmployerJobsStatus? status,
    List<EmployerJobEntity>? jobs,
    EmployerJobsFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmployerJobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
