import '../entities/favourite_worker_entity.dart';

abstract interface class EmployerFavouriteWorkersRepository {
  Future<List<FavouriteWorkerEntity>> getFavouriteWorkers();

  Future<void> toggleFavourite(String workerId);
}
