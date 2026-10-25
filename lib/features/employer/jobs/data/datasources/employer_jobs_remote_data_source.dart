import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_job_entity.dart';
import '../models/employer_job_model.dart';

class EmployerJobsRemoteDataSource {
  EmployerJobsRemoteDataSource(this._apiClient, this._getSupabaseClient);

  final ApiClient _apiClient;
  final SupabaseClient Function() _getSupabaseClient;

  Future<List<EmployerJobEntity>> getEmployerJobs() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.employerJobs,
    );

    final responseData = response.data;

    if (responseData == null) {
      throw Exception('Invalid response received from the server.');
    }

    if (responseData['success'] != true) {
      throw Exception(
        responseData['message']?.toString() ?? 'Failed to fetch jobs.',
      );
    }

    final data = responseData['data'];

    if (data is! List) {
      throw Exception('Invalid jobs data received from the server.');
    }

    final jobs = data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    if (jobs.isEmpty) return const [];

    final jobIds = jobs
        .map((job) {
          final id = job['id']?.toString();
          if (id == null || id.isEmpty) {
            throw const FormatException('A job was returned without an ID.');
          }
          return id;
        })
        .toList(growable: false);

    final slotRows = await _getSupabaseClient().rpc(
      'get_employer_job_scheduled_slots',
      params: {'p_job_ids': jobIds},
    );
    if (slotRows is! List) {
      throw const PostgrestException(
        message: 'Invalid job time-slot data received from the database.',
      );
    }

    final slotsByJobId = <String, List<String>>{};
    for (final row in slotRows) {
      if (row is! Map) {
        throw const PostgrestException(
          message: 'Invalid job time-slot data received from the database.',
        );
      }
      final jobId = row['job_id']?.toString();
      final slots = row['scheduled_slots'];
      if (jobId == null || slots is! List) {
        throw const PostgrestException(
          message: 'Invalid job time-slot data received from the database.',
        );
      }
      slotsByJobId[jobId] = slots
          .map((slot) => slot?.toString().trim() ?? '')
          .where((slot) => slot.isNotEmpty)
          .toList(growable: false);
    }

    if (jobIds.any((jobId) => !slotsByJobId.containsKey(jobId))) {
      throw const PostgrestException(
        message: 'The database did not return time slots for every job.',
      );
    }

    return jobs
        .map((job) {
          final jobId = job['id']?.toString();
          if (jobId != null && slotsByJobId.containsKey(jobId)) {
            job['scheduled_slots'] = slotsByJobId[jobId];
          }
          return EmployerJobModel.fromJson(job).toEntity();
        })
        .toList(growable: false);
  }

  Future<void> cancelJob(String jobId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.jobCancel(jobId),
    );

    final responseData = response.data;

    if (responseData == null) {
      throw Exception('Invalid response received from the server.');
    }

    if (responseData['success'] != true) {
      throw Exception(
        responseData['message']?.toString() ?? 'Failed to cancel job.',
      );
    }
  }
}
