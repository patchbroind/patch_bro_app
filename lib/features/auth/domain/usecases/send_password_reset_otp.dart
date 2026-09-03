import '../repositories/auth_repository.dart';

class SendPasswordResetOtp {
  const SendPasswordResetOtp(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String phone,
  }) {
    return _repository.sendPasswordResetOtp(
      phone: phone,
    );
  }
}