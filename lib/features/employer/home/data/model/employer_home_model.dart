import 'dart:convert';
import 'dart:typed_data';

import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

import '../../domain/entities/employer_home_entity.dart';

class EmployerHomeModel extends EmployerHomeEntity {
  const EmployerHomeModel({required super.name, super.avatarUrl, super.location});

  factory EmployerHomeModel.fromMap(Map<String, dynamic> map, {String? avatarUrl}) {
    return EmployerHomeModel(
      name: _readName(map['name']),
      avatarUrl: avatarUrl,
      location: _parseLocation(map['location'], map['location_address']),
    );
  }

  // ================================================================
  // NAME
  // ================================================================

  static String _readName(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return 'User';
  }

  // ================================================================
  // LOCATION
  // ================================================================

  static ProfileLocation? _parseLocation(dynamic rawLocation, dynamic rawAddress) {
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

  // ================================================================
  // PARSE COORDINATES
  // ================================================================

  static (double, double)? _parseCoordinates(dynamic value) {
    if (value == null) {
      return null;
    }

    // ------------------------------------------------------------
    // CASE 1:
    // WKT
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
      // CASE 2:
      // JSON / GeoJSON
      // ----------------------------------------------------------

      try {
        final decoded = jsonDecode(text);

        final coordinates = _parseCoordinates(decoded);

        if (coordinates != null) {
          return coordinates;
        }
      } catch (_) {
        // Not JSON.
      }

      // ----------------------------------------------------------
      // CASE 3:
      // PostGIS EWKB hexadecimal
      //
      // Example:
      //
      // 0101000020E6100000000000DA42665340...
      // ----------------------------------------------------------

      final ewkbCoordinates = _parseEwkbHex(text);

      if (ewkbCoordinates != null) {
        return ewkbCoordinates;
      }

      return null;
    }

    // ------------------------------------------------------------
    // CASE 4:
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

  // ================================================================
  // POSTGIS EWKB HEX PARSER
  // ================================================================

  static (double, double)? _parseEwkbHex(String value) {
    final hex = value.trim();

    // A Point with SRID needs at least:
    //
    // 4 bytes  -> type
    // 4 bytes  -> SRID
    // 8 bytes  -> X / longitude
    // 8 bytes  -> Y / latitude
    //
    // Total = 24 bytes = 48 hex characters.

    if (hex.length < 48 || hex.length.isOdd || !RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hex)) {
      return null;
    }

    try {
      final bytes = Uint8List(hex.length ~/ 2);

      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }

      final data = ByteData.sublistView(bytes);

      // ----------------------------------------------------------
      // Byte order
      // ----------------------------------------------------------

      final byteOrder = bytes[0];

      final endian = byteOrder == 1 ? Endian.little : Endian.big;

      // ----------------------------------------------------------
      // Geometry type
      // ----------------------------------------------------------

      final geometryType = data.getUint32(1, endian);

      final hasZ = (geometryType & 0x80000000) != 0;

      final hasM = (geometryType & 0x40000000) != 0;

      final hasSrid = (geometryType & 0x20000000) != 0;

      // We only expect Point geometry here.
      final baseType = geometryType & 0x0FFFFFFF;

      if (baseType != 1) {
        return null;
      }

      // ----------------------------------------------------------
      // Coordinates start after:
      //
      // 1 byte  byte order
      // 4 bytes geometry type
      // optional 4 bytes SRID
      // ----------------------------------------------------------

      int offset = 5;

      if (hasSrid) {
        offset += 4;
      }

      if (bytes.length < offset + 16) {
        return null;
      }

      final longitude = data.getFloat64(offset, endian);

      final latitude = data.getFloat64(offset + 8, endian);

      // We don't need Z/M for ProfileLocation.
      //
      // The variables are intentionally calculated so this parser
      // also documents that the EWKB flags are understood.
      if (hasZ) {
        // Z follows X/Y.
      }

      if (hasM) {
        // M follows X/Y (or Z).
      }

      if (!longitude.isFinite || !latitude.isFinite) {
        return null;
      }

      // Basic geographic sanity check.
      if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        return null;
      }

      return (latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  // ================================================================
  // DOUBLE CONVERSION
  // ================================================================

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}
