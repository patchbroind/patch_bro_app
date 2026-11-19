
import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

import '../models/worker_job_progress_model.dart';

class WorkerJobProgressRemoteDataSource {
  WorkerJobProgressRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<WorkerJobProgressModel> updateProgress({
    required String jobId,
    required String status,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.workerJobProgress(jobId),
      data: {
        'status': status,
      },
    );

    final responseData = response.data;

    if (responseData is! Map ||
        responseData['data'] is! Map) {
      throw const FormatException(
        'Invalid worker progress response',
      );
    }

    return WorkerJobProgressModel.fromMap(
      Map<String, dynamic>.from(responseData['data']),
    );
  }
}
