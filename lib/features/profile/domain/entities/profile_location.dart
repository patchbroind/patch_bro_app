class ProfileLocation {
  const ProfileLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.state,
    this.postCode,
    this.country,
  });

  final double latitude;
  final double longitude;

  final String address;

  final String? city;
  final String? state;
  final String? postCode;
  final String? country;
}