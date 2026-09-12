import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_benefit_entity.dart';

class EmployerBenefitRemoteDataSource {
  EmployerBenefitRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<EmployerBenefitEntity> getBenefitDetails() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    /*
     * Temporary UI data: current migrations do not define job, benefit,
     * or milestone tables/RPCs. Replace this method when that backend
     * contract exists; callers depend only on EmployerBenefitRepository.
     */
    return const EmployerBenefitEntity(
      qualifyingWorkerJobs: 7,
      requiredWorkerJobs: 10,
      isEligible: false,
      benefitTitle: 'Employer Fee Benefit',
      benefitDescription:
          'Complete qualifying jobs as a Worker to unlock a special discount on Employer platform fees.',
      remainingJobsDescription: 'More qualifying jobs are needed to unlock your benefit.',
    );
  }
}
