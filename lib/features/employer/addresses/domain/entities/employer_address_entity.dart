import 'package:flutter/foundation.dart';

@immutable
class EmployerAddressEntity {
  const EmployerAddressEntity({
    required this.id,
    required this.address,
    this.addressLine2,
    this.state,
    this.postalCode,
    this.locationAddress,
  });

  final String id;
  final String address;
  final String? addressLine2;
  final String? state;
  final String? postalCode;
  final String? locationAddress;

  String get formattedAddress {
    final parts = <String>[
      address,
      if (addressLine2?.trim().isNotEmpty == true) addressLine2!.trim(),
      if (locationAddress?.trim().isNotEmpty == true) locationAddress!.trim(),
      if (state?.trim().isNotEmpty == true) state!.trim(),
      if (postalCode?.trim().isNotEmpty == true) postalCode!.trim(),
    ];
    return parts.join(', ');
  }
}
