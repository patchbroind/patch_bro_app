import '../repositories/auth_repository.dart';

class UpdatePhone {
  const UpdatePhone(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String phone,
  }) {
    return _repository.updatePhone(
      phone: phone,
    );
  }
}