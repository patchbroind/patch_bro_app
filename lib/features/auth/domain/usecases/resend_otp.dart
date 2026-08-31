import '../repositories/auth_repository.dart';

class ResendOtp {
  const ResendOtp(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String phone,
  }) {
    return _repository.resendOtp(
      phone: phone,
    );
  }
}