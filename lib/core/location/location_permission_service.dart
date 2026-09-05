import 'package:geolocator/geolocator.dart';

class LocationPermissionService {
  const LocationPermissionService();

  Future<void> ensurePermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }
  }
}

class LocationServiceDisabledException
    implements Exception {
  const LocationServiceDisabledException();

  @override
  String toString() {
    return 'Location services are disabled. Please enable location services and try again.';
  }
}

class LocationPermissionDeniedException
    implements Exception {
  const LocationPermissionDeniedException();

  @override
  String toString() {
    return 'Location permission was denied.';
  }
}

class LocationPermissionPermanentlyDeniedException
    implements Exception {
  const LocationPermissionPermanentlyDeniedException();

  @override
  String toString() {
    return 'Location permission was permanently denied. Please enable location permission from app settings.';
  }
}