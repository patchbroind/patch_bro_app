import '../../../profile/domain/entities/profile_data.dart';

class OtpVerificationArgs {
  const OtpVerificationArgs({
    required this.phone,
    required this.type,
    this.profileData,
  });

  factory OtpVerificationArgs.phoneChange({
    required String phone,
    required ProfileData profileData,
  }) {
    return OtpVerificationArgs(
      phone: phone,
      type: OtpVerificationType.phoneChange,
      profileData: profileData,
    );
  }

  final String phone;
  final OtpVerificationType type;
  final ProfileData? profileData;
}

enum OtpVerificationType {
  signup,
  phoneChange,
}