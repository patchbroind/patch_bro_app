import '../../domain/entities/worker_home_job_entity.dart';
import '../../domain/repository/worker_home_repository.dart';
import '../datasource/worker_home_remote_data_source.dart';

class WorkerHomeRepositoryImpl implements WorkerHomeRepository {
  WorkerHomeRepositoryImpl(this._remoteDataSource);

  final WorkerHomeRemoteDataSource _remoteDataSource;

  @override
  Future<List<WorkerHomeJobEntity>> getAssignedJobs() async {
    final models = await _remoteDataSource.getAssignedJobs();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }
}
