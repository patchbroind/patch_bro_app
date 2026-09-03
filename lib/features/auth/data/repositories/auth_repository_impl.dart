import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map(
      (state) {
        final user = state.session?.user;

        if (user == null) {
          return null;
        }

        return AuthUserModel.fromSupabaseUser(user).toEntity();
      },
    );
  }

  @override
  AuthUser? get currentUser {
    final user = _remoteDataSource.currentUser;

    if (user == null) {
      return null;
    }

    return AuthUserModel.fromSupabaseUser(user).toEntity();
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
      throw const AuthException(
        'Unable to create user.',
      );
    }

    return AuthUserModel.fromSupabaseUser(user).toEntity();
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
      throw const AuthException(
        'OTP verification failed.',
      );
    }

    return AuthUserModel.fromSupabaseUser(user).toEntity();
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
      throw const AuthException(
        'Unable to sign in.',
      );
    }

    return AuthUserModel.fromSupabaseUser(user).toEntity();
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
    final response = await _remoteDataSource.verifyPhoneChangeOtp(
      phone: phone,
      token: token,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException(
        'Phone verification failed.',
      );
    }

    return AuthUserModel.fromSupabaseUser(user).toEntity();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }
}