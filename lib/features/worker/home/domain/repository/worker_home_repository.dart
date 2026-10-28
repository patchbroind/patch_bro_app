import '../entities/worker_home_job_entity.dart';

abstract interface class WorkerHomeRepository {
  Future<List<WorkerHomeJobEntity>> getAssignedJobs();
}
