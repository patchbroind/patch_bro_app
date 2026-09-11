import 'package:supabase_flutter/supabase_flutter.dart';

class EmployerHomeRemoteDataSource {
  EmployerHomeRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<Map<String, dynamic>?> getHomeData() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    return _supabase
        .from('profiles')
        .select('id, name, location, location_address')
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    await _supabase
        .from('profiles')
        .update({
          'location': 'POINT($longitude $latitude)',
          'location_address': address.trim(),
        })
        .eq('id', user.id);
  }

  String? getAvatarUrl() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final metadata = user.userMetadata;

    final avatarUrl =
        metadata?['avatar_url'] ?? metadata?['picture'] ?? metadata?['avatar'];

    if (avatarUrl is String && avatarUrl.trim().isNotEmpty) {
      return avatarUrl.trim();
    }

    return null;
  }
}
