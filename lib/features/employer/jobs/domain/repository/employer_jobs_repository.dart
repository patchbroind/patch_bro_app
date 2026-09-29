import '../entities/employer_job_entity.dart';

abstract interface class EmployerJobsRepository {
  Future<List<EmployerJobEntity>> getEmployerJobs();

  Future<void> cancelJob(String jobId);
}