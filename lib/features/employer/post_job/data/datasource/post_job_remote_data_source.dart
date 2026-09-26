import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

import '../../../jobs/data/models/employer_job_model.dart';

class PostJobRemoteDataSource {
  const PostJobRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // ===========================================================================
  // CREATE JOB
  // ===========================================================================

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
  }) async {
    final formData = FormData();

    _addCommonJobFields(
      formData,
      category: category,
      skill: skill,
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      description: description,
    );

    // -------------------------------------------------------------------------
    // Images
    // -------------------------------------------------------------------------

    final selectedImages = images.take(2).toList();

    for (final image in selectedImages) {
      if (!await image.exists()) {
        throw Exception('Selected job image could not be found.');
      }

      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(image.path, filename: _fileName(image))),
      );
    }

    // -------------------------------------------------------------------------
    // Voice
    // -------------------------------------------------------------------------

    if (voiceRecording != null) {
      if (!await voiceRecording.exists()) {
        throw Exception('Voice recording could not be found.');
      }

      formData.files.add(
        MapEntry(
          'audio',
          await MultipartFile.fromFile(voiceRecording.path, filename: _fileName(voiceRecording)),
        ),
      );
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.employerJobs,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final responseData = response.data;

    if (responseData == null) {
      throw Exception('Invalid response received from the server.');
    }

    if (responseData['success'] != true) {
      throw Exception(responseData['message']?.toString() ?? 'Failed to create job.');
    }

    final data = responseData['data'];

    if (data is! Map) {
      throw Exception('Invalid job creation response.');
    }

    final jobId = data['job_id']?.toString();

    if (jobId == null || jobId.isEmpty) {
      throw Exception('The server did not return the created job ID.');
    }

    return jobId;
  }

  // ===========================================================================
  // UPDATE JOB
  // ===========================================================================

  Future<EmployerJobModel> updateJob({
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
    final formData = FormData();

    _addCommonJobFields(
      formData,
      category: category,
      skill: skill,
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      description: description,
    );

    // -------------------------------------------------------------------------
    // Existing images
    //
    // The backend receives the images that should remain.
    // Any existing image not included in this list will be deleted.
    // -------------------------------------------------------------------------

    formData.fields.add(MapEntry('keep_image_paths', jsonEncode(keepImagePaths)));

    // -------------------------------------------------------------------------
    // Existing audio path
    //
    // The current backend determines the existing audio from job_media.
    // We still pass this value so the request contract remains explicit.
    // -------------------------------------------------------------------------

    if (existingAudioPath != null && existingAudioPath.trim().isNotEmpty) {
      formData.fields.add(MapEntry('existing_audio_path', existingAudioPath));
    }

    // -------------------------------------------------------------------------
    // Existing audio deletion
    // -------------------------------------------------------------------------

    formData.fields.add(MapEntry('delete_audio', removeExistingAudio ? 'true' : 'false'));

    // -------------------------------------------------------------------------
    // New images
    // -------------------------------------------------------------------------

    for (final image in newImages) {
      if (!await image.exists()) {
        throw Exception('Selected job image could not be found.');
      }

      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(image.path, filename: _fileName(image))),
      );
    }

    // -------------------------------------------------------------------------
    // New audio
    //
    // The backend treats a supplied audio file as a replacement for
    // the existing audio.
    // -------------------------------------------------------------------------

    if (newAudio != null) {
      if (!await newAudio.exists()) {
        throw Exception('New voice recording could not be found.');
      }

      formData.files.add(
        MapEntry(
          'audio',
          await MultipartFile.fromFile(newAudio.path, filename: _fileName(newAudio)),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // PATCH
    // -------------------------------------------------------------------------

    final response = await _apiClient.patch<Map<String, dynamic>>(
      '${ApiEndpoints.employerJobs}/$jobId',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final responseData = response.data;

    if (responseData == null) {
      throw Exception('Invalid response received from the server.');
    }

    if (responseData['success'] != true) {
      throw Exception(responseData['message']?.toString() ?? 'Failed to update job.');
    }

    final data = responseData['data'];

    if (data is! Map) {
      throw Exception('Invalid job update response.');
    }

    final jobData = data['job'];

    if (jobData is! Map) {
      throw Exception('The server did not return the updated job.');
    }

    return EmployerJobModel.fromJson(Map<String, dynamic>.from(jobData));
  }

  // ===========================================================================
  // COMMON JOB FIELDS
  // ===========================================================================

  void _addCommonJobFields(
    FormData formData, {
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
  }) {
    formData.fields.add(MapEntry('category', category));

    formData.fields.add(MapEntry('skill', skill));

    formData.fields.add(MapEntry('scheduled_date', _formatDate(date)));

    formData.fields.add(MapEntry('scheduled_time', _formatTime(time)));

    formData.fields.add(MapEntry('latitude', latitude.toString()));

    formData.fields.add(MapEntry('longitude', longitude.toString()));

    formData.fields.add(MapEntry('location_address', locationAddress));

    formData.fields.add(MapEntry('description', description));
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');

    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _fileName(File file) {
    final path = file.path;

    final separatorIndex = path.lastIndexOf(Platform.pathSeparator);

    if (separatorIndex == -1) {
      return path;
    }

    return path.substring(separatorIndex + 1);
  }
}
