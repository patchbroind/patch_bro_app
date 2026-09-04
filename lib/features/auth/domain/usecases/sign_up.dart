import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String phone,
    required String email,
    required String password,
    required String appFlavor,
  }) {
    return _repository.signUp(
      phone: phone,
      email: email,
      password: password,
      appFlavor: appFlavor,
    );
  }
}