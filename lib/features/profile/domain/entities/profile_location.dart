class ProfileLocation {
  const ProfileLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.district,
    this.state,
    this.postCode,
    this.country,
  });

  final double latitude;
  final double longitude;
  final String address;

  /// Local place / locality.
  final String? city;

  /// District / sub-administrative area.
  final String? district;

  /// State.
  final String? state;

  final String? postCode;
  final String? country;
}