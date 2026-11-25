
import '../entities/job_sheet_entity.dart';

abstract class JobSheetRepository {
  Future<JobSheetEntity?> getJobSheet(String jobId);

  Future<JobSheetEntity> submitJobSheet(
    JobSheetSubmission submission,
  );
}