import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_job_entity.dart';

class EmployerJobsRemoteDataSource {
  EmployerJobsRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<EmployerJobEntity>> getEmployerJobs() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    /*
     * Temporary backend boundary: current migrations contain no jobs table,
     * status contract, amount fields, or image fields. Return no jobs until
     * that schema is defined rather than guessing table or column names.
     * Replace only this method when the backend contract is available.
     */
    return const <EmployerJobEntity>[];
  }
}
