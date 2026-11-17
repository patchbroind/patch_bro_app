
import 'package:flutter/foundation.dart';
import 'package:patch_bro/features/worker/home/domain/entities/worker_home_job_entity.dart';

enum WorkerJobsTab {
  upcoming,
  completed,
  cancelled,
}

@immutable
class WorkerJobsState {
  const WorkerJobsState({
    this.isLoading = false,
    this.jobs = const [],
    this.selectedTab = WorkerJobsTab.upcoming,
    this.errorMessage,
  });

  final bool isLoading;
  final List<WorkerHomeJobEntity> jobs;
  final WorkerJobsTab selectedTab;
  final String? errorMessage;

  bool get hasJobs => jobs.isNotEmpty;

  bool get hasError => errorMessage != null;

  // Compare calendar dates rather than timestamps.
  bool _isExpired(DateTime scheduledDate) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final jobDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    return jobDate.isBefore(today);
  }

  List<WorkerHomeJobEntity> get filteredJobs {
    final filtered = jobs.where((job) {
      final status = job.status.trim().toLowerCase();

      final isCompleted = status == 'completed';

      final isCancelled = {
        'cancelled',
        'canceled',
        'expired',
      }.contains(status);

      final isExpired = _isExpired(job.scheduledDate);

      switch (selectedTab) {
        case WorkerJobsTab.upcoming:
          // Only active, non-expired jobs.
          return !isCompleted &&
              !isCancelled &&
              !isExpired;

        case WorkerJobsTab.completed:
          return isCompleted;

        case WorkerJobsTab.cancelled:
          // Include explicitly cancelled/expired jobs
          // and jobs whose scheduled date has passed.
          // Completed jobs must remain in Completed.
          return !isCompleted &&
              (isCancelled || isExpired);
      }
    }).toList();

    if (selectedTab == WorkerJobsTab.upcoming) {
      filtered.sort(
        (a, b) => a.scheduledDate.compareTo(b.scheduledDate),
      );
    } else {
      filtered.sort(
        (a, b) => b.scheduledDate.compareTo(a.scheduledDate),
      );
    }

    return List.unmodifiable(filtered);
  }

  WorkerJobsState copyWith({
    bool? isLoading,
    List<WorkerHomeJobEntity>? jobs,
    WorkerJobsTab? selectedTab,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkerJobsState(
      isLoading: isLoading ?? this.isLoading,
      jobs: jobs ?? this.jobs,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
