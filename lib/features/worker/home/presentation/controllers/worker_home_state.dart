import 'package:flutter/foundation.dart';
import '../../domain/entities/worker_home_job_entity.dart';

@immutable
class WorkerHomeState {
  const WorkerHomeState({
    this.isLoading = false,
    this.jobs = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<WorkerHomeJobEntity> jobs;
  final String? errorMessage;

  bool get hasJobs => jobs.isNotEmpty;

  WorkerHomeState copyWith({
    bool? isLoading,
    List<WorkerHomeJobEntity>? jobs,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkerHomeState(
      isLoading: isLoading ?? this.isLoading,
      jobs: jobs ?? this.jobs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
