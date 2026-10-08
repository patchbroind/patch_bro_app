import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';

import '../../domain/entities/employer_address_entity.dart';

class EmployerAddressesRemoteDataSource {
  EmployerAddressesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<EmployerAddressEntity>> getAddresses() async {
    final response = await _apiClient.get(ApiEndpoints.employerAddresses);

    final responseData = response.data;

    if (responseData is! Map) {
      return const <EmployerAddressEntity>[];
    }

    final data = responseData['data'];

    if (data is! List) {
      return const <EmployerAddressEntity>[];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => EmployerAddressEntity(
            id: item['id']?.toString() ?? '',
            address: item['address']?.toString().trim() ?? '',
            addressLine2: _nullableString(item['address_line_2']),
            state: _nullableString(item['state']),
            postalCode: _nullableString(item['postal_code']),
            locationAddress: _nullableString(item['location_address']),
          ),
        )
        .toList(growable: false);
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }
}
