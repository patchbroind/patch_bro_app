import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_address_entity.dart';

class EmployerAddressesRemoteDataSource {
  EmployerAddressesRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<EmployerAddressEntity>> getAddresses() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final profile = await _supabase
        .from('profiles')
        .select('id, address_1, address_2, state, pin_code, location_address')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      return const <EmployerAddressEntity>[];
    }

    final address = (profile['address_1'] as String?)?.trim() ?? '';
    if (address.isEmpty) {
      return const <EmployerAddressEntity>[];
    }

    return [
      EmployerAddressEntity(
        id: user.id,
        address: address,
        addressLine2: (profile['address_2'] as String?)?.trim(),
        state: (profile['state'] as String?)?.trim(),
        postalCode: (profile['pin_code'] as String?)?.trim(),
        locationAddress: (profile['location_address'] as String?)?.trim(),
      ),
    ];
  }
}
