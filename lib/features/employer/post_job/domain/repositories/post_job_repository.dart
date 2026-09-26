import 'dart:io';

import '../../../jobs/domain/entities/employer_job_entity.dart';

abstract class PostJobRepository {
  Future<String?> createJob({
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
    required File? voiceRecording,
    required List<File> images,
  });

  Future<EmployerJobEntity> updateJob({
    required String jobId,
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
    required List<String> keepImagePaths,
    required List<File> newImages,
    required String? existingAudioPath,
    required bool removeExistingAudio,
    required File? newAudio,
  });
}