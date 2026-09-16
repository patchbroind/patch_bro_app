import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

abstract interface class EmployerWorkersRepository {
  Future<List<EmployerWorkerEntity>> getWorkers();

  Future<void> toggleFavourite(String workerId);
}
