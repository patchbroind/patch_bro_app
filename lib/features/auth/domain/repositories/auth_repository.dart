import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  AuthUser? get currentUser;

  Future<AuthUser> signUp({
    required String phone,
    required String email,
    required String password,
    required String appFlavor,
  });

  Future<AuthUser> verifyOtp({required String phone, required String token});

  Future<void> resendOtp({required String phone});

  Future<AuthUser> signIn({required String phone, required String password});

  Future<void> signOut();


}
