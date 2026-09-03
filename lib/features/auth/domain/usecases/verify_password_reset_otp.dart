import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyPasswordResetOtp {
  const VerifyPasswordResetOtp(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String phone,
    required String token,
  }) {
    return _repository.verifyPasswordResetOtp(
      phone: phone,
      token: token,
    );
  }
}