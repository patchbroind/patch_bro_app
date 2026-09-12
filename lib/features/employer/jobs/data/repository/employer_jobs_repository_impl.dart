import '../../domain/entities/employer_job_entity.dart';
import '../../domain/repository/employer_jobs_repository.dart';
import '../datasources/employer_jobs_remote_data_source.dart';

class EmployerJobsRepositoryImpl implements EmployerJobsRepository {
  EmployerJobsRepositoryImpl(this._remoteDataSource);

  final EmployerJobsRemoteDataSource _remoteDataSource;

  @override
  Future<List<EmployerJobEntity>> getEmployerJobs() {
    return _remoteDataSource.getEmployerJobs();
  }
}
