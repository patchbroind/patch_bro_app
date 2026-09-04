import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String redirectTo,
  }) {
    return _repository.signInWithGoogle(
      redirectTo: redirectTo,
    );
  }
}