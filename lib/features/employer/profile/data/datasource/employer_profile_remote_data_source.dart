import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

import '../../domain/entities/employer_profile_entity.dart';

class EmployerProfileRemoteDataSource {
  EmployerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<EmployerProfileEntity> getEmployerProfile() async {
    final response = await _apiClient.get(ApiEndpoints.employerProfile);

    final responseData = response.data;

    if (responseData is! Map) {
      throw Exception('Invalid employer profile response.');
    }

    final data = responseData['data'];

    if (data is! Map) {
      throw Exception('Employer profile not found.');
    }

    return EmployerProfileEntity(
      id: data['id']?.toString() ?? '',
      fullName: data['full_name']?.toString().trim() ?? data['name']?.toString().trim() ?? '',
      roleLabel: data['role_label']?.toString() ?? 'Employer',
      isTrusted: data['is_trusted'] == true,
      jobsPosted: _intValue(data['jobs_posted']),
      jobsCompleted: _intValue(data['jobs_completed']),
      cancelledJobs: _intValue(data['cancelled_jobs']),
      successfulJobs: _intValue(data['successful_jobs']),
      hasWorkerProfile: data['has_worker_profile'] == true,
      qualifyingWorkerJobs: _intValue(data['qualifying_worker_jobs']),
      requiredWorkerJobs: _intValue(data['required_worker_jobs']),
      platformFeeBenefitEligible: data['platform_fee_benefit_eligible'] == true,
      phone: _nullableString(data['phone']),
      avatarUrl: _nullableString(data['avatar_url']),
      phoneVerified: data['phone_verified'] == true,
      email: _nullableString(data['email']),
      emailVerified: data['email_verified'] == true,
      locationAddress: _nullableString(data['location_address']),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }
}
