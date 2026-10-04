import 'package:geocoding/geocoding.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

class GeocodingService {
  GeocodingService({
    Geocoding? geocoding,
  }) : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  // ================================================================
  // GET FULL LOCATION
  // ================================================================

  Future<ProfileLocation> getLocationFromCoordinates({
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
        return ProfileLocation(
          latitude: latitude,
          longitude: longitude,
          address: 'Selected location',
        );
      }

      final place = placemarks.first;

      // ------------------------------------------------------------
      // PLACE / CITY
      // ------------------------------------------------------------

      final city = _firstNonEmpty([
        place.locality,
        place.subLocality,
        place.name,
      ]);

      // ------------------------------------------------------------
      // DISTRICT
      // ------------------------------------------------------------

      final district = _firstNonEmpty([
        place.subAdministrativeArea,
      ]);

      // ------------------------------------------------------------
      // STATE
      // ------------------------------------------------------------

      final state = _firstNonEmpty([
        place.administrativeArea,
      ]);

      // ------------------------------------------------------------
      // POST CODE
      // ------------------------------------------------------------

      final postCode = _firstNonEmpty([
        place.postalCode,
      ]);

      // ------------------------------------------------------------
      // COUNTRY
      // ------------------------------------------------------------

      final country = _firstNonEmpty([
        place.country,
      ]);

      // ------------------------------------------------------------
      // SHORT DISPLAY ADDRESS
      //
      // Example:
      //
      // Kallur, Thrissur, Kerala
      // ------------------------------------------------------------

      final address = _buildAddress(
        city: city,
        district: district,
        state: state,
      );

      return ProfileLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
        city: city,
        district: district,
        state: state,
        postCode: postCode,
        country: country,
      );
    } catch (_) {
      return ProfileLocation(
        latitude: latitude,
        longitude: longitude,
        address: 'Selected location',
      );
    }
  }

  // ================================================================
  // GET ADDRESS ONLY
  //
  // Kept for compatibility with LocationService.
  // ================================================================

  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final location = await getLocationFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );

    return location.address;
  }

  // ================================================================
  // FIRST NON-EMPTY VALUE
  // ================================================================

  String? _firstNonEmpty(
    List<String?> values,
  ) {
    for (final value in values) {
      final trimmed = value?.trim();

      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return null;
  }

  // ================================================================
  // BUILD SHORT ADDRESS
  // ================================================================

  String _buildAddress({
    String? city,
    String? district,
    String? state,
  }) {
    final parts = <String>[];

    void add(String? value) {
      if (value == null || value.trim().isEmpty) {
        return;
      }

      final trimmed = value.trim();

      if (!parts.contains(trimmed)) {
        parts.add(trimmed);
      }
    }

    add(city);
    add(district);
    add(state);

    if (parts.isEmpty) {
      return 'Selected location';
    }

    return parts.join(', ');
  }
}