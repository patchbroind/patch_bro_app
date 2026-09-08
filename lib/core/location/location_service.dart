import 'package:geolocator/geolocator.dart';

import 'geocoding_service.dart';
import 'location_permission_service.dart';

class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

class LocationService {
  LocationService({
    LocationPermissionService? permissionService,
    GeocodingService? geocodingService,
  })  : permissionService =
            permissionService ?? const LocationPermissionService(),
        geocodingService =
            geocodingService ?? GeocodingService();

  final LocationPermissionService permissionService;
  final GeocodingService geocodingService;

  Future<LocationResult> getCurrentLocation() async {
    await permissionService.ensurePermission();

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final address =
        await geocodingService.getAddressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );
  }

  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    return geocodingService.getAddressFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }
}