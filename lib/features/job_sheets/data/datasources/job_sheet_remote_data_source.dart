import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoinds.dart';
import '../../domain/entities/job_sheet_entity.dart';
import '../models/job_sheet_model.dart';

abstract class JobSheetRemoteDataSource {
  Future<JobSheetEntity?> getJobSheet(String jobId);

  Future<JobSheetEntity> submitJobSheet(
    JobSheetSubmission submission,
  );
}

class JobSheetRemoteDataSourceImpl
    implements JobSheetRemoteDataSource {
  JobSheetRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<JobSheetEntity?> getJobSheet(String jobId) async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.jobSheet(jobId),
    );

    final responseData = _asMap(response.data);
    final data = responseData['data'];

    if (data == null) return null;

    return JobSheetModel.fromJson(_asMap(data));
  }

  @override
  Future<JobSheetEntity> submitJobSheet(
    JobSheetSubmission submission,
  ) async {
    if (submission.imagePaths.length > 5) {
      throw Exception('Maximum 5 images are allowed.');
    }

    final formData = FormData();

    formData.fields.add(
      MapEntry('work_summary', submission.workSummary.trim()),
    );

    formData.fields.add(
      MapEntry(
        'additional_notes',
        submission.additionalNotes?.trim() ?? '',
      ),
    );

    formData.fields.add(
      MapEntry(
        'materials_used',
        submission.materialsUsed?.trim() ?? '',
      ),
    );

    for (final imagePath in submission.imagePaths) {
      final fileName = _fileName(imagePath);
      final mimeType = _mimeType(imagePath);

      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            imagePath,
            filename: fileName,
            contentType: DioMediaType.parse(mimeType),
          ),
        ),
      );
    }

    final audioPath = submission.audioPath;

    if (audioPath != null && audioPath.trim().isNotEmpty) {
      formData.files.add(
        MapEntry(
          'audio',
          await MultipartFile.fromFile(
            audioPath,
            filename: _fileName(audioPath),
            contentType: DioMediaType.parse(_mimeType(audioPath)),
          ),
        ),
      );
    }

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.jobSheet(submission.jobId),
      data: formData,
    );

    final responseData = _asMap(response.data);
    final data = responseData['data'];

    if (data == null) {
      throw Exception('Job Sheet was submitted but no data was returned.');
    }

    return JobSheetModel.fromJson(_asMap(data));
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  String _fileName(String filePath) {
    return filePath.split(RegExp(r'[/\\]')).last;
  }

  String _mimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'webm':
        return 'audio/webm';
      case 'ogg':
        return 'audio/ogg';
      default:
        throw Exception('Unsupported file format: $extension');
    }
  }
}