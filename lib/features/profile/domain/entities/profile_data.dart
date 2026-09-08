import 'profile_location.dart';

class ProfileData {
  const ProfileData({
    required this.name,
    required this.phone,
    required this.address1,
    required this.address2,
    required this.pinCode,
    required this.state,
    required this.location,
    required this.isWorker,
  });

  final String name;
  final String phone;
  final String address1;
  final String address2;
  final String pinCode;
  final String state;
  final ProfileLocation location;
  final bool isWorker;
}