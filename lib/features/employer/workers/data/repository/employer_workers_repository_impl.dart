import 'package:patch_bro/features/employer/workers/data/datasource/employer_workers_remote_data_source.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:patch_bro/features/employer/workers/domain/repository/employer_workers_repository.dart';

class EmployerWorkersRepositoryImpl implements EmployerWorkersRepository {
  EmployerWorkersRepositoryImpl(this._remoteDataSource);

  final EmployerWorkersRemoteDataSource _remoteDataSource;

  @override
  Future<List<EmployerWorkerEntity>> getWorkers() {
    return _remoteDataSource.getWorkers();
  }

  @override
  Future<void> toggleFavourite(String workerId) {
    return _remoteDataSource.toggleFavourite(workerId);
  }
}
