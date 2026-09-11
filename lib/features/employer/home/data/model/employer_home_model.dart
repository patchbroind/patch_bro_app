import 'dart:convert';

import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

import '../../domain/entities/employer_home_entity.dart';

class EmployerHomeModel extends EmployerHomeEntity {
  const EmployerHomeModel({
    required super.name,
    super.avatarUrl,
    super.location,
  });

  factory EmployerHomeModel.fromMap(
    Map<String, dynamic> map, {
    String? avatarUrl,
  }) {
    return EmployerHomeModel(
      name: _readName(map['name']),
      avatarUrl: avatarUrl,
      location: _parseLocation(map['location'], map['location_address']),
    );
  }

  static String _readName(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return 'User';
  }

  static ProfileLocation? _parseLocation(
    dynamic rawLocation,
    dynamic rawAddress,
  ) {
    final address = rawAddress is String ? rawAddress.trim() : '';

    final coordinates = _parseCoordinates(rawLocation);

    if (coordinates == null) {
      return null;
    }

    return ProfileLocation(
      latitude: coordinates.$1,
      longitude: coordinates.$2,
      address: address.isNotEmpty ? address : 'Selected location',
    );
  }

  static (double, double)? _parseCoordinates(dynamic value) {
    if (value == null) {
      return null;
    }

    // ------------------------------------------------------------
    // PostGIS WKT
    //
    // POINT(longitude latitude)
    // ------------------------------------------------------------

    if (value is String) {
      final text = value.trim();

      final match = RegExp(
        r'^POINT\s*\(\s*'
        r'(-?\d+(?:\.\d+)?)'
        r'\s+'
        r'(-?\d+(?:\.\d+)?)'
        r'\s*\)$',
        caseSensitive: false,
      ).firstMatch(text);

      if (match != null) {
        final longitude = double.tryParse(match.group(1)!);

        final latitude = double.tryParse(match.group(2)!);

        if (latitude != null && longitude != null) {
          return (latitude, longitude);
        }
      }

      // ----------------------------------------------------------
      // JSON / GeoJSON
      // ----------------------------------------------------------

      try {
        final decoded = jsonDecode(text);

        return _parseCoordinates(decoded);
      } catch (_) {
        return null;
      }
    }

    // ------------------------------------------------------------
    // GeoJSON object
    // ------------------------------------------------------------

    if (value is Map) {
      final coordinates = value['coordinates'];

      if (coordinates is List && coordinates.length >= 2) {
        final longitude = _toDouble(coordinates[0]);

        final latitude = _toDouble(coordinates[1]);

        if (latitude != null && longitude != null) {
          return (latitude, longitude);
        }
      }

      final geometry = value['geometry'];

      if (geometry != null) {
        return _parseCoordinates(geometry);
      }
    }

    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}
