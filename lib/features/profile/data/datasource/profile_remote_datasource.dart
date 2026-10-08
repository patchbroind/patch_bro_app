import 'dart:developer';

import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // ================================================================
  // SAVE PROFILE
  // ================================================================

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address1,
    String? address2,
    required String pinCode,
    required String state,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required bool isWorker,
  }) async {
    await _apiClient.put(
      ApiEndpoints.profile,
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'address_1': address1.trim(),
        'address_2': address2?.trim().isEmpty == true
            ? null
            : address2?.trim(),
        'pin_code': pinCode.trim(),
        'state': state.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress.trim(),
        'is_worker': isWorker,
      },
    );
  }

  // ================================================================
  // GET CURRENT PROFILE
  // ================================================================

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.profile,
    );

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
  // UPDATE PROFILE LOCATION
  // ================================================================

  Future<void> updateProfileLocation({
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.profileLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress.trim(),
      },
    );
  }

  // ================================================================
  // WORKER PROFILE CHECK
  // ================================================================

  Future<bool> hasWorkerProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.workerProfileStatus,
    );

    final responseData = response.data;

    log("it is the worker response data: $responseData");

    if (responseData is! Map) {
      return false;
    }

    final data = responseData['data'];

    if (data is! Map) {
      return false;
    }

    return data['exists'] == true;
  }

  // ================================================================
  // EMPLOYER PROFILE CHECK
  // ================================================================

  Future<bool> hasEmployerProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.employerProfileStatus,
    );


    final responseData = response.data;

    log("it is the response data: $responseData");

    if (responseData is! Map) {
      return false;
    }

    final data = responseData['data'];

    if (data is! Map) {
      return false;
    }

    return data['exists'] == true;
  }
}