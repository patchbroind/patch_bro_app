import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class EmployerHomeRemoteDataSource {
  EmployerHomeRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ================================================================
  // GET HOME DATA
  // ================================================================

  Future<Map<String, dynamic>?> getHomeData() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final homeData = await _supabase
        .from('profiles')
        .select('id, name, location, location_address')
        .eq('id', user.id)
        .maybeSingle();
      log("it is homeData: $homeData");
        return homeData;
  }

  // ================================================================
  // UPDATE LOCATION
  // ================================================================

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final location = 'POINT($longitude $latitude)';

    final updatedRow = await _supabase
        .from('profiles')
        .update({'location': location, 'location_address': address.trim()})
        .eq('id', user.id)
        .select('id, name, location, location_address')
        .single();

    return updatedRow;
  }

  // ================================================================
  // AVATAR
  // ================================================================

  String? getAvatarUrl() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final metadata = user.userMetadata;

    final avatarUrl = metadata?['avatar_url'] ?? metadata?['picture'] ?? metadata?['avatar'];

    if (avatarUrl is String && avatarUrl.trim().isNotEmpty) {
      return avatarUrl.trim();
    }

    return null;
  }
}
