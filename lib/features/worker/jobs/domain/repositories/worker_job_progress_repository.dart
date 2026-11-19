

import 'package:patch_bro/features/worker/jobs/domain/eintities/worker_job_progress_entity.dart';

abstract interface class WorkerJobProgressRepository {
  Future<WorkerJobProgressEntity> updateProgress({
    required String jobId,
    required String status,
  });
}
