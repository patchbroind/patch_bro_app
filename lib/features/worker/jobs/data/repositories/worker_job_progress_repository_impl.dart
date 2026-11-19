
import 'package:patch_bro/features/worker/jobs/domain/eintities/worker_job_progress_entity.dart';

import '../../domain/repositories/worker_job_progress_repository.dart';
import '../datasources/worker_job_progress_remote_data_source.dart';

class WorkerJobProgressRepositoryImpl
    implements WorkerJobProgressRepository {
  WorkerJobProgressRepositoryImpl(this._remoteDataSource);

  final WorkerJobProgressRemoteDataSource _remoteDataSource;

  @override
  Future<WorkerJobProgressEntity> updateProgress({
    required String jobId,
    required String status,
  }) async {
    final model = await _remoteDataSource.updateProgress(
      jobId: jobId,
      status: status,
    );

    return model.toEntity();
  }
}
