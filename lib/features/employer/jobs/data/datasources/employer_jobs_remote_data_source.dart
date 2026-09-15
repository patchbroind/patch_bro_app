import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

import '../../domain/entities/employer_job_entity.dart';
import '../models/employer_job_model.dart';

class EmployerJobsRemoteDataSource {
  EmployerJobsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<EmployerJobEntity>> getEmployerJobs() async {
    final response =
        await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.employerJobs,
    );

    final responseData = response.data;

    if (responseData == null) {
      throw Exception(
        'Invalid response received from the server.',
      );
    }

    if (responseData['success'] != true) {
      throw Exception(
        responseData['message']?.toString() ??
            'Failed to fetch jobs.',
      );
    }

    final data = responseData['data'];

    if (data is! List) {
      throw Exception(
        'Invalid jobs data received from the server.',
      );
    }

    final models = data
        .map(
          (item) => EmployerJobModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();

    return models
        .map((model) => model.toEntity())
        .toList();
  }
}