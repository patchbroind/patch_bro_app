import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';
import 'package:patch_bro/features/worker/home/data/models/worker_home_job_model.dart';

class WorkerHomeRemoteDataSource {
  WorkerHomeRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<WorkerHomeJobModel>> getAssignedJobs() async {
    final response = await _apiClient.get(ApiEndpoints.workerJobs);

    final responseData = response.data;
    if (responseData is! Map || responseData['data'] is! List) {
      return const [];
    }

    final rawJobs = responseData['data'] as List;
    return rawJobs
        .whereType<Map>()
        .map((item) => WorkerHomeJobModel.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
