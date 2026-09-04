import '../repositories/auth_repository.dart';

class UpdatePassword {
  const UpdatePassword(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String password,
  }) {
    return _repository.updatePassword(
      password: password,
    );
  }
}