import 'dart:io';

import '../../domain/repositories/post_job_repository.dart';
import '../datasource/post_job_remote_data_source.dart';

class PostJobRepositoryImpl
    implements PostJobRepository {
  PostJobRepositoryImpl(
    this._remoteDataSource,
  );

  final PostJobRemoteDataSource
      _remoteDataSource;

  @override
  Future<String> createJob({
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
    File? voiceRecording,
    required List<File> images,
  }) {
    return _remoteDataSource.createJob(
      category: category,
      skill: skill,
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      locationAddress:
          locationAddress,
      description: description,
      voiceRecording:
          voiceRecording,
      images: images,
    );
  }
}