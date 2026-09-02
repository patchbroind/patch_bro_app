import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address1,
    String? address2,
    required String pinCode,
    required String state,
    required bool isWorker,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    final userId = user.id;

    // Save common profile information.
    await _supabase.from('profiles').upsert(
      {
        'id': userId,
        'name': name.trim(),
        'phone': phone.trim(),
        'address_1': address1.trim(),
        'address_2': address2?.trim(),
        'pin_code': pinCode.trim(),
        'state': state.trim(),
      },
      onConflict: 'id',
    );

    // Create the role-specific profile.
    if (isWorker) {
      await _supabase
          .from('worker_profiles')
          .upsert(
        {
          'id': userId,
        },
        onConflict: 'id',
      );
    } else {
      await _supabase
          .from('employer_profiles')
          .upsert(
        {
          'id': userId,
        },
        onConflict: 'id',
      );
    }
  }

  Future<bool> hasWorkerProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    final result = await _supabase
        .from('worker_profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    return result != null;
  }

  Future<bool> hasEmployerProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    final result = await _supabase
        .from('employer_profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    return result != null;
  }
}