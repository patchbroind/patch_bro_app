import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

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
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    final userId = user.id;

    // PostGIS uses:
    //
    // POINT(longitude latitude)
    //
    final location = 'POINT($longitude $latitude)';

    await _supabase.from('profiles').upsert(
      {
        'id': userId,
        'name': name.trim(),
        'phone': phone.trim(),
        'address_1': address1.trim(),
        'address_2': address2?.trim().isEmpty == true
            ? null
            : address2?.trim(),
        'pin_code': pinCode.trim(),
        'state': state.trim(),
        'location': location,
        'location_address': locationAddress.trim(),
      },
      onConflict: 'id',
    );

    // ==============================================================
    // ROLE-SPECIFIC PROFILE
    // ==============================================================

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

  // ================================================================
  // GET CURRENT PROFILE
  // ================================================================

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    return _supabase
        .from('profiles')
        .select(
          'id, name, phone, address_1, address_2, '
          'pin_code, state, location, location_address',
        )
        .eq('id', user.id)
        .maybeSingle();
  }

  // ================================================================
  // UPDATE PROFILE LOCATION
  // ================================================================

  Future<void> updateProfileLocation({
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    final location = 'POINT($longitude $latitude)';

    await _supabase
        .from('profiles')
        .update({
          'location': location,
          'location_address': locationAddress.trim(),
        })
        .eq('id', user.id);
  }

  // ================================================================
  // WORKER PROFILE CHECK
  // ================================================================

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

  // ================================================================
  // EMPLOYER PROFILE CHECK
  // ================================================================

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