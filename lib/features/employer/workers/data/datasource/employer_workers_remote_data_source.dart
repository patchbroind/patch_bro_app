import 'package:patch_bro/features/employer/workers/data/models/employer_worker_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployerWorkersRemoteDataSource {
  EmployerWorkersRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ============================================================
  // GET WORKERS
  // ============================================================

  Future<List<EmployerWorkerModel>> getWorkers() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final response = await _supabase.rpc('get_employer_workers');

    if (response is! List) {
      throw const PostgrestException(message: 'Invalid workers response.');
    }

    return response
        .map(
          (row) => EmployerWorkerModel.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  // ============================================================
  // TOGGLE FAVOURITE
  // ============================================================

  Future<void> toggleFavourite(String workerId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final existing = await _supabase
        .from('employer_worker_favourites')
        .select('employer_id')
        .eq('employer_id', user.id)
        .eq('worker_id', workerId)
        .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('employer_worker_favourites')
          .delete()
          .eq('employer_id', user.id)
          .eq('worker_id', workerId);

      return;
    }

    await _supabase.from('employer_worker_favourites').insert({
      'employer_id': user.id,
      'worker_id': workerId,
    });
  }
}
