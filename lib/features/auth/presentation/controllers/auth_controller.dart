import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  // ================================================================
  // SIGN UP
  // ================================================================

  Future<void> signUp({
    required String phone,
    required String email,
    required String password,
    required String appFlavor,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(signUpProvider)(
        phone: phone,
        email: email,
        password: password,
        appFlavor: appFlavor,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // VERIFY SIGNUP OTP
  // ================================================================

  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(verifyOtpProvider)(
        phone: phone,
        token: token,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // RESEND OTP
  // ================================================================

  Future<void> resendOtp({
    required String phone,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(resendOtpProvider)(
        phone: phone,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // SEND PASSWORD RESET OTP
  // ================================================================

  Future<void> sendPasswordResetOtp({
    required String phone,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(sendPasswordResetOtpProvider)(
        phone: phone,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // VERIFY PASSWORD RESET OTP
  // ================================================================

  Future<void> verifyPasswordResetOtp({
    required String phone,
    required String token,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(verifyPasswordResetOtpProvider)(
        phone: phone,
        token: token,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // UPDATE PASSWORD
  // ================================================================

  Future<void> updatePassword({
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(updatePasswordProvider)(
        password: password,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // SIGN IN
  // ================================================================

  Future<void> signIn({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(signInProvider)(
        phone: phone,
        password: password,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // GOOGLE SIGN IN
  // ================================================================

  Future<void> signInWithGoogle({
    required String redirectTo,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(signInWithGoogleProvider)(
        redirectTo: redirectTo,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // UPDATE PHONE
  // ================================================================

  Future<void> updatePhone({
    required String phone,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(updatePhoneProvider)(
        phone: phone,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // VERIFY PHONE CHANGE OTP
  // ================================================================

  Future<void> verifyPhoneChangeOtp({
    required String phone,
    required String token,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(verifyPhoneChangeOtpProvider)(
        phone: phone,
        token: token,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // ================================================================
  // SIGN OUT
  // ================================================================

  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await ref.read(signOutProvider)();

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}