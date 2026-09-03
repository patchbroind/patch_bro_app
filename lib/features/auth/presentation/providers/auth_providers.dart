import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/app/config/app_config.dart';
import 'package:patch_bro/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:patch_bro/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:patch_bro/features/auth/domain/entities/auth_user.dart';
import 'package:patch_bro/features/auth/domain/repositories/auth_repository.dart';
import 'package:patch_bro/features/auth/domain/usecases/resend_otp.dart';
import 'package:patch_bro/features/auth/domain/usecases/send_password_reset_otp.dart';
import 'package:patch_bro/features/auth/domain/usecases/sign_in.dart';
import 'package:patch_bro/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:patch_bro/features/auth/domain/usecases/sign_out.dart';
import 'package:patch_bro/features/auth/domain/usecases/sign_up.dart';
import 'package:patch_bro/features/auth/domain/usecases/update_password.dart';
import 'package:patch_bro/features/auth/domain/usecases/update_phone.dart';
import 'package:patch_bro/features/auth/domain/usecases/verify_otp.dart';
import 'package:patch_bro/features/auth/domain/usecases/verify_password_reset_otp.dart';
import 'package:patch_bro/features/auth/domain/usecases/verify_phone_change_otp.dart';
import 'package:patch_bro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

// ==================================================================
// APP CONFIG
// ==================================================================

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

// ==================================================================
// SUPABASE CLIENT
// ==================================================================

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ==================================================================
// AUTH REMOTE DATA SOURCE
// ==================================================================

final authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(supabaseClientProvider),
  );
});

// ==================================================================
// AUTH REPOSITORY
// ==================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  );
});

// ==================================================================
// SIGN UP
// ==================================================================

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// VERIFY SIGNUP OTP
// ==================================================================

final verifyOtpProvider = Provider<VerifyOtp>((ref) {
  return VerifyOtp(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// RESEND OTP
// ==================================================================

final resendOtpProvider = Provider<ResendOtp>((ref) {
  return ResendOtp(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// SEND PASSWORD RESET OTP
// ==================================================================

final sendPasswordResetOtpProvider =
    Provider<SendPasswordResetOtp>((ref) {
  return SendPasswordResetOtp(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// VERIFY PASSWORD RESET OTP
// ==================================================================

final verifyPasswordResetOtpProvider =
    Provider<VerifyPasswordResetOtp>((ref) {
  return VerifyPasswordResetOtp(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// UPDATE PASSWORD
// ==================================================================

final updatePasswordProvider = Provider<UpdatePassword>((ref) {
  return UpdatePassword(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// SIGN IN
// ==================================================================

final signInProvider = Provider<SignIn>((ref) {
  return SignIn(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// GOOGLE SIGN IN
// ==================================================================

final signInWithGoogleProvider =
    Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// UPDATE PHONE
// ==================================================================

final updatePhoneProvider = Provider<UpdatePhone>((ref) {
  return UpdatePhone(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// VERIFY PHONE CHANGE OTP
// ==================================================================

final verifyPhoneChangeOtpProvider =
    Provider<VerifyPhoneChangeOtp>((ref) {
  return VerifyPhoneChangeOtp(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// SIGN OUT
// ==================================================================

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(
    ref.watch(authRepositoryProvider),
  );
});

// ==================================================================
// AUTH STATE
// ==================================================================

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ==================================================================
// CURRENT USER
// ==================================================================

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

// ==================================================================
// AUTH CONTROLLER
// ==================================================================

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);