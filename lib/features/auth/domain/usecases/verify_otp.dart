import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String phone,
    required String token,
  }) {
    return _repository.verifyOtp(
      phone: phone,
      token: token,
    );
  }
}