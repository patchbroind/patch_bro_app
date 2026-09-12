import '../../domain/entities/favourite_worker_entity.dart';
import '../../domain/repository/employer_favourite_workers_repository.dart';
import '../datasources/employer_favourite_workers_remote_data_source.dart';

class EmployerFavouriteWorkersRepositoryImpl implements EmployerFavouriteWorkersRepository {
  EmployerFavouriteWorkersRepositoryImpl(this._remoteDataSource);

  final EmployerFavouriteWorkersRemoteDataSource _remoteDataSource;

  @override
  Future<List<FavouriteWorkerEntity>> getFavouriteWorkers() {
    return _remoteDataSource.getFavouriteWorkers();
  }

  @override
  Future<void> toggleFavourite(String workerId) {
    return _remoteDataSource.toggleFavourite(workerId);
  }
}
