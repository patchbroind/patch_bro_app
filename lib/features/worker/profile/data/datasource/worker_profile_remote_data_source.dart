import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';
import 'package:patch_bro/features/worker/profile/data/models/worker_profile_model.dart';

class WorkerProfileRemoteDataSource {
  WorkerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // ============================================================
  // GET CURRENT WORKER PROFILE
  // ============================================================

  Future<WorkerProfileModel?> getCurrentProfile() async {
    final response = await _apiClient.get(ApiEndpoints.workerProfile);

    final responseData = response.data;

    if (responseData is! Map) {
      return null;
    }

    final data = responseData['data'];

    if (data is! Map) {
      return null;
    }

    return WorkerProfileModel.fromMap(Map<String, dynamic>.from(data));
  }

  // ============================================================
  // SAVE WORKER PROFILE
  // ============================================================

  Future<void> saveProfile({
    required String profession,
    required List<String> skills,
    required String about,
    required int experienceYears,
    required List<String> availabilityDays,
    required bool availableToday,
    required bool availableTomorrow,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.workerProfile,
      data: {
        'profession': profession.trim(),
        'skills': skills,
        'about': about.trim(),
        'experience_years': experienceYears,
        'availability_days': availabilityDays,
        'available_today': availableToday,
        'available_tomorrow': availableTomorrow,
      },
    );
  }
}
