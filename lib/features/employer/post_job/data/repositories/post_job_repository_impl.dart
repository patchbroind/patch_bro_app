import 'dart:io';

import 'package:patch_bro/features/employer/post_job/data/datasource/post_job_remote_data_source.dart';

import '../../domain/repositories/post_job_repository.dart';

class PostJobRepositoryImpl implements PostJobRepository {
  final PostJobRemoteDataSource _remoteDataSource;

  PostJobRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createJob({
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
      locationAddress: locationAddress,
      description: description,
      voiceRecording: voiceRecording,
      images: images,
    );
  }
}