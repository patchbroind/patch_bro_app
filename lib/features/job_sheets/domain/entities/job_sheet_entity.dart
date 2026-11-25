
class JobSheetMediaEntity {
  const JobSheetMediaEntity({
    required this.mediaType,
    required this.url,
    this.mimeType,
    this.fileSize,
    this.sortOrder = 0,
  });

  final String mediaType;
  final String url;
  final String? mimeType;
  final int? fileSize;
  final int sortOrder;
}

class JobSheetEntity {
  const JobSheetEntity({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.employerId,
    required this.workSummary,
    required this.submittedAt,
    required this.workerName,
    required this.originalJob,
    required this.originalMedia,
    required this.workerImages,
    this.additionalNotes,
    this.materialsUsed,
    this.workerAudio,
  });

  final String id;
  final String jobId;
  final String workerId;
  final String employerId;
  final String workSummary;
  final String? additionalNotes;
  final String? materialsUsed;
  final DateTime submittedAt;
  final String workerName;

  /// Original job details and attachments, preserved by the backend.
  final Map<String, dynamic> originalJob;

  final List<JobSheetMediaEntity> originalMedia;
  final List<JobSheetMediaEntity> workerImages;
  final JobSheetMediaEntity? workerAudio;
}

/// Input required when the worker submits a Job Sheet.
class JobSheetSubmission {
  const JobSheetSubmission({
    required this.jobId,
    required this.workSummary,
    this.additionalNotes,
    this.materialsUsed,
    this.imagePaths = const [],
    this.audioPath,
  });

  final String jobId;
  final String workSummary;
  final String? additionalNotes;
  final String? materialsUsed;
  final List<String> imagePaths;
  final String? audioPath;
}