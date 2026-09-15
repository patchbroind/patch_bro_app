import 'dart:io';

import 'package:dio/dio.dart';
import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

class PostJobRemoteDataSource {
  PostJobRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

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
  }) async {
    final formData = FormData();

    // ------------------------------------------------------------
    // JOB DETAILS
    // ------------------------------------------------------------

    formData.fields.add(
      MapEntry('category', category),
    );

    formData.fields.add(
      MapEntry('skill', skill),
    );

    formData.fields.add(
      MapEntry(
        'scheduled_date',
        _formatDate(date),
      ),
    );

    formData.fields.add(
      MapEntry(
        'scheduled_time',
        _formatTime(time),
      ),
    );

    formData.fields.add(
      MapEntry(
        'latitude',
        latitude.toString(),
      ),
    );

    formData.fields.add(
      MapEntry(
        'longitude',
        longitude.toString(),
      ),
    );

    formData.fields.add(
      MapEntry(
        'location_address',
        locationAddress,
      ),
    );

    formData.fields.add(
      MapEntry(
        'description',
        description,
      ),
    );

    // ------------------------------------------------------------
    // IMAGES
    // ------------------------------------------------------------

    // Backend currently supports a maximum of 2 images.
    final limitedImages = images.take(2).toList();

    for (final image in limitedImages) {
      if (!await image.exists()) {
        throw Exception(
          'Selected job image could not be found.',
        );
      }

      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename: _fileName(image),
          ),
        ),
      );
    }

    // ------------------------------------------------------------
    // VOICE DESCRIPTION
    // ------------------------------------------------------------

    if (voiceRecording != null) {
      if (!await voiceRecording.exists()) {
        throw Exception(
          'Voice recording could not be found.',
        );
      }

      formData.files.add(
        MapEntry(
          'audio',
          await MultipartFile.fromFile(
            voiceRecording.path,
            filename: _fileName(voiceRecording),
          ),
        ),
      );
    }

    // ------------------------------------------------------------
    // API REQUEST
    // ------------------------------------------------------------

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.employerJobs,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final responseData = response.data;

    if (responseData == null) {
      throw Exception(
        'Invalid response received from the server.',
      );
    }

    final success = responseData['success'];

    if (success != true) {
      final message =
          responseData['message']?.toString() ??
          'Failed to create job.';

      throw Exception(message);
    }
  }

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

    final separatorIndex = path.lastIndexOf(
      Platform.pathSeparator,
    );

    if (separatorIndex == -1) {
      return path;
    }

    return path.substring(separatorIndex + 1);
  }
}