import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  // ============================================================
  // Sign Up
  // ============================================================

  Future<AuthUser> signUp({
    required String phone,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final config = ref.read(appConfigProvider);

      final user = await ref.read(signUpProvider).call(
            phone: phone,
            email: email,
            password: password,
            appFlavor: config.flavor.name,
          );

      state = const AsyncData(null);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  // ============================================================
  // Verify OTP
  // ============================================================

  Future<AuthUser> verifyOtp({
    required String phone,
    required String token,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref.read(verifyOtpProvider).call(
            phone: phone,
            token: token,
          );

      state = const AsyncData(null);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  // ============================================================
  // Resend OTP
  // ============================================================

  Future<void> resendOtp({
    required String phone,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(resendOtpProvider).call(
            phone: phone,
          );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  // ============================================================
  // Sign In
  // ============================================================

  Future<AuthUser> signIn({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref.read(signInProvider).call(
            phone: phone,
            password: password,
          );

      state = const AsyncData(null);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  // ============================================================
  // Sign Out
  // ============================================================

  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await ref.read(signOutProvider).call();

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      rethrow;
    }
  }
}