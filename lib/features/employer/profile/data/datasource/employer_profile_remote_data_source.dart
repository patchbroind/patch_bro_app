import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_profile_entity.dart';

class EmployerProfileRemoteDataSource {
  EmployerProfileRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<EmployerProfileEntity> getEmployerProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final profile = await _supabase
        .from('profiles')
        .select('id, name, phone, location_address')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw const PostgrestException(message: 'Employer profile not found.');
    }

    final avatarUrl =
        user.userMetadata?['avatar_url'] ??
        user.userMetadata?['picture'] ??
        user.userMetadata?['avatar'];

    return EmployerProfileEntity(
      id: user.id,
      fullName: (profile['name'] as String?)?.trim() ?? '',
      roleLabel: 'Employer',
      isTrusted: false,
      jobsPosted: 0,
      jobsCompleted: 0,
      cancelledJobs: 0,
      successfulJobs: 0,
      hasWorkerProfile: false,
      qualifyingWorkerJobs: 0,
      requiredWorkerJobs: 0,
      platformFeeBenefitEligible: false,
      phone: (profile['phone'] as String?)?.trim(),
      avatarUrl: avatarUrl is String && avatarUrl.trim().isNotEmpty ? avatarUrl.trim() : null,
      phoneVerified: user.phoneConfirmedAt != null,
      email: user.email,
      emailVerified: user.emailConfirmedAt != null,
      locationAddress: (profile['location_address'] as String?)?.trim(),
    );
  }
}
