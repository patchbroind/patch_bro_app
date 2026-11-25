import '../../domain/entities/job_sheet_entity.dart';

class JobSheetModel {
  static JobSheetEntity fromJson(Map<String, dynamic> json) {
    final originalJob = _asMap(json['original_job']);
    final workerMedia = _asMap(json['worker_media']);

    final originalMedia = _asList(originalJob['original_media'])
        .map(JobSheetModel._mediaFromJson)
        .toList();

    final workerImages = _asList(workerMedia['images'])
        .map(JobSheetModel._mediaFromJson)
        .toList();

    final audioJson = workerMedia['audio'];

    return JobSheetEntity(
      id: _string(json['id']),
      jobId: _string(json['job_id']),
      workerId: _string(json['worker_id']),
      employerId: _string(json['employer_id']),
      workSummary: _string(json['work_summary']),
      additionalNotes: _nullableString(json['additional_notes']),
      materialsUsed: _nullableString(json['materials_used']),
      submittedAt: DateTime.parse(_string(json['submitted_at'])),
      workerName: _string(json['worker_name']).isEmpty
          ? 'Worker'
          : _string(json['worker_name']),
      originalJob: originalJob,
      originalMedia: originalMedia,
      workerImages: workerImages,
      workerAudio: audioJson is Map
          ? _mediaFromJson(Map<String, dynamic>.from(audioJson))
          : null,
    );
  }

  static JobSheetMediaEntity _mediaFromJson(
    Map<String, dynamic> json,
  ) {
    return JobSheetMediaEntity(
      mediaType: _string(json['media_type']),
      url: _string(json['url']),
      mimeType: _nullableString(json['mime_type']),
      fileSize: _intValue(json['file_size']),
      sortOrder: _intValue(json['sort_order']) ?? 0,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String _string(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}