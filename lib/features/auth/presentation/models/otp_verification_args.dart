import 'package:patch_bro/features/profile/domain/entities/profile_data.dart';

enum OtpVerificationType {
  signup,
  phoneChange,
  passwordReset,
}

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

  factory OtpVerificationArgs.passwordReset({
    required String phone,
  }) {
    return OtpVerificationArgs(
      phone: phone,
      type: OtpVerificationType.passwordReset,
    );
  }

  final String phone;
  final OtpVerificationType type;
  final ProfileData? profileData;
}