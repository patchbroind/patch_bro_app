
import '../../domain/entities/job_sheet_entity.dart';
import '../../domain/repositories/job_sheet_repository.dart';
import '../datasources/job_sheet_remote_data_source.dart';

class JobSheetRepositoryImpl implements JobSheetRepository {
  JobSheetRepositoryImpl(this._remoteDataSource);

  final JobSheetRemoteDataSource _remoteDataSource;

  @override
  Future<JobSheetEntity?> getJobSheet(String jobId) {
    return _remoteDataSource.getJobSheet(jobId);
  }

  @override
  Future<JobSheetEntity> submitJobSheet(
    JobSheetSubmission submission,
  ) {
    return _remoteDataSource.submitJobSheet(submission);
  }
}