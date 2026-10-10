import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

class EmployerHomeRemoteDataSource {
  EmployerHomeRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // ================================================================
  // GET HOME DATA
  // ================================================================

  Future<Map<String, dynamic>?> getHomeData() async {
    final response = await _apiClient.get(ApiEndpoints.employerHome);

    final responseData = response.data;

    if (responseData is! Map) {
      return null;
    }

    final data = responseData['data'];

    if (data is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  // ================================================================
  // UPDATE LOCATION
  // ================================================================

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.profileLocation,
      data: {'latitude': latitude, 'longitude': longitude, 'location_address': address.trim()},
    );

    final responseData = response.data;

    if (responseData is! Map) {
      return {};
    }

    final data = responseData['data'];

    if (data is! Map) {
      return {};
    }

    return Map<String, dynamic>.from(data);
  }

  // ================================================================
  // AVATAR
  // ================================================================

  String? getAvatarUrl() {
    return null;
  }
}
