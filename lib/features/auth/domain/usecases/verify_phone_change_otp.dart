import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneChangeOtp {
  const VerifyPhoneChangeOtp(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String phone,
    required String token,
  }) {
    return _repository.verifyPhoneChangeOtp(
      phone: phone,
      token: token,
    );
  }
}