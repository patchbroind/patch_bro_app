import 'package:geocoding/geocoding.dart';

class GeocodingService {
  GeocodingService({
    Geocoding? geocoding,
  }) : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks =
          await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return 'Selected location';
      }

      final place = placemarks.first;

      final parts = <String>[
        if ((place.name ?? '').trim().isNotEmpty)
          place.name!.trim(),

        if ((place.street ?? '').trim().isNotEmpty)
          place.street!.trim(),

        if ((place.locality ?? '').trim().isNotEmpty)
          place.locality!.trim(),

        if ((place.subAdministrativeArea ?? '').trim().isNotEmpty)
          place.subAdministrativeArea!.trim(),

        if ((place.administrativeArea ?? '').trim().isNotEmpty)
          place.administrativeArea!.trim(),

        if ((place.postalCode ?? '').trim().isNotEmpty)
          place.postalCode!.trim(),

        if ((place.country ?? '').trim().isNotEmpty)
          place.country!.trim(),
      ];

      if (parts.isEmpty) {
        return 'Selected location';
      }

      return parts.join(', ');
    } catch (_) {
      return 'Selected location';
    }
  }
}