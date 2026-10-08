import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

import 'package:patch_bro/features/employer/workers/data/models/employer_worker_model.dart';

class EmployerWorkersRemoteDataSource {
  EmployerWorkersRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // ============================================================
  // GET WORKERS
  // ============================================================

  Future<List<EmployerWorkerModel>> getWorkers() async {
    final response = await _apiClient.get(ApiEndpoints.employerWorkers);

    final responseData = response.data;

    if (responseData is! Map) {
      return const <EmployerWorkerModel>[];
    }

    final data = responseData['data'];

    if (data is! List) {
      return const <EmployerWorkerModel>[];
    }

    return data
        .whereType<Map>()
        .map((row) => EmployerWorkerModel.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  // ============================================================
  // TOGGLE FAVOURITE
  // ============================================================

  Future<void> toggleFavourite(String workerId) async {
    await _apiClient.patch(ApiEndpoints.employerWorkerFavourite(workerId));
  }
}
