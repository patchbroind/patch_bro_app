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

    /*
     * ------------------------------------------------------------
     * TEMPORARY PROFILE DATA
     * ------------------------------------------------------------
     *
     * The actual employer_profiles table/query will be connected
     * once the final Supabase schema for employer_profiles and
     * its aggregate statistics is available.
     *
     * Do not remove this abstraction. The repository/controller
     * architecture is already ready for the real data source.
     */

    return const EmployerProfileEntity(
      id: 'demo-employer',
      fullName: 'Mohammed Shafi',
      roleLabel: 'Employer',
      isTrusted: true,
      jobsPosted: 18,
      jobsCompleted: 15,
      cancelledJobs: 2,
      successfulJobs: 12,
      hasWorkerProfile: true,
      qualifyingWorkerJobs: 7,
      requiredWorkerJobs: 10,
      platformFeeBenefitEligible: false,
    );
  }
}