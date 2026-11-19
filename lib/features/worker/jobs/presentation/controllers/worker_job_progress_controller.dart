
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/features/worker/jobs/presentation/providers/worker_job_progress_providers.dart';

import '../../domain/repositories/worker_job_progress_repository.dart';
import 'worker_job_progress_state.dart';

class WorkerJobProgressController
    extends Notifier<WorkerJobProgressState> {
  WorkerJobProgressController(this.args);

  final (String, String) args;

  late String _jobId;

  late WorkerJobProgressRepository _repository;

  @override
  WorkerJobProgressState build() {
    _jobId = args.$1;

    _repository = ref.read(
      workerJobProgressRepositoryProvider,
    );

    return WorkerJobProgressState(
      status: args.$2,
    );
  }

  Future<bool> advance() async {
    if (state.isLoading) return false;

    String? nextStatus;

    switch (state.status) {
      case 'not_started':
        nextStatus = 'on_the_way';
        break;

      case 'on_the_way':
        nextStatus = 'reached';
        break;

      case 'reached':
        return false;

      default:
        return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.updateProgress(
        jobId: _jobId,
        status: nextStatus,
      );

      state = state.copyWith(
        status: nextStatus,
        isLoading: false,
        clearError: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }
}
