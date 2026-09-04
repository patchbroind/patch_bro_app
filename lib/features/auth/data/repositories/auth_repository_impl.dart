import 'package:patch_bro/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:patch_bro/features/auth/data/models/auth_user_model.dart';
import 'package:patch_bro/features/auth/domain/entities/auth_user.dart';
import 'package:patch_bro/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map(
      (authState) {
        final user = authState.session?.user;

        if (user == null) {
          return null;
        }

        return AuthUserModel
            .fromSupabaseUser(user)
            .toEntity();
      },
    );
  }

  @override
  AuthUser? get currentUser {
    final user = _remoteDataSource.currentUser;

    if (user == null) {
      return null;
    }

    return AuthUserModel
        .fromSupabaseUser(user)
        .toEntity();
  }

  @override
  Future<AuthUser> signUp({
    required String phone,
    required String email,
    required String password,
    required String appFlavor,
  }) async {
    final response = await _remoteDataSource.signUp(
      phone: phone,
      email: email,
      password: password,
      appFlavor: appFlavor,
    );

    final user = response.user;

    if (user == null) {
      throw StateError(
        'Signup completed without returning a user.',
      );
    }

    return AuthUserModel
        .fromSupabaseUser(user)
        .toEntity();
  }

  @override
  Future<AuthUser> verifyOtp({
    required String phone,
    required String token,
  }) async {
    final response = await _remoteDataSource.verifyOtp(
      phone: phone,
      token: token,
    );

    final user = response.user;

    if (user == null) {
      throw StateError(
        'OTP verification completed without returning a user.',
      );
    }

    return AuthUserModel
        .fromSupabaseUser(user)
        .toEntity();
  }

  @override
  Future<void> resendOtp({
    required String phone,
  }) {
    return _remoteDataSource.resendOtp(
      phone: phone,
    );
  }

  @override
  Future<void> sendPasswordResetOtp({
    required String phone,
  }) {
    return _remoteDataSource.sendPasswordResetOtp(
      phone: phone,
    );
  }

  @override
  Future<AuthUser> verifyPasswordResetOtp({
    required String phone,
    required String token,
  }) async {
    final response =
        await _remoteDataSource.verifyPasswordResetOtp(
      phone: phone,
      token: token,
    );

    final user = response.user;

    if (user == null) {
      throw StateError(
        'Password reset OTP verification completed without returning a user.',
      );
    }

    return AuthUserModel
        .fromSupabaseUser(user)
        .toEntity();
  }

  @override
  Future<void> updatePassword({
    required String password,
  }) {
    return _remoteDataSource.updatePassword(
      password: password,
    );
  }

  @override
  Future<AuthUser> signIn({
    required String phone,
    required String password,
  }) async {
    final response = await _remoteDataSource.signIn(
      phone: phone,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw StateError(
        'Login completed without returning a user.',
      );
    }

    return AuthUserModel
        .fromSupabaseUser(user)
        .toEntity();
  }

  @override
  Future<void> signInWithGoogle({
    required String redirectTo,
  }) {
    return _remoteDataSource.signInWithGoogle(
      redirectTo: redirectTo,
    );
  }

  @override
  Future<void> updatePhone({
    required String phone,
  }) {
    return _remoteDataSource.updatePhone(
      phone: phone,
    );
  }

  @override
  Future<AuthUser> verifyPhoneChangeOtp({
    required String phone,
    required String token,
  }) async {
    final response =
        await _remoteDataSource.verifyPhoneChangeOtp(
      phone: phone,
      token: token,
    );

    final user = response.user;

    if (user == null) {
      throw StateError(
        'Phone change OTP verification completed without returning a user.',
      );
    }

    return AuthUserModel
        .fromSupabaseUser(user)
        .toEntity();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }
}