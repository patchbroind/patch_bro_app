import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_trust_entity.dart';

class EmployerTrustRemoteDataSource {
  EmployerTrustRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<EmployerTrustEntity> getTrustDetails() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    /*
     * Temporary UI data: the current migrations do not define job,
     * cancellation, or trust tables/RPCs. Replace this method with the
     * real query when that backend contract is added; callers already depend
     * only on EmployerTrustRepository.
     */
    return const EmployerTrustEntity(
      isTrusted: true,
      successfulJobs: 12,
      cancellationCount: 2,
      isGoodStanding: true,
      trustRequirementsMet: true,
      successfulJobsRequired: 10,
      maxCancellationsForTrust: 6,
      jobsRequiredToRegainTrust: 5,
    );
  }
}
