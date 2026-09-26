import 'dart:io';

import '../../../jobs/domain/entities/employer_job_entity.dart';
import '../../domain/repositories/post_job_repository.dart';
import '../datasource/post_job_remote_data_source.dart';

class PostJobRepositoryImpl implements PostJobRepository {
  const PostJobRepositoryImpl(
    this._remoteDataSource,
  );

  final PostJobRemoteDataSource _remoteDataSource;

  @override
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
  }) {
    return _remoteDataSource.createJob(
      category: category,
      skill: skill,
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      description: description,
      voiceRecording: voiceRecording,
      images: images,
    );
  }

  @override
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
  }) async {
    final model =
        await _remoteDataSource.updateJob(
      jobId: jobId,
      category: category,
      skill: skill,
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      description: description,
      keepImagePaths: keepImagePaths,
      newImages: newImages,
      existingAudioPath: existingAudioPath,
      removeExistingAudio:
          removeExistingAudio,
      newAudio: newAudio,
    );

    return model.toEntity();
  }
}