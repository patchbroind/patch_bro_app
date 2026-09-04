import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  Future<AuthResponse> signUp({
    required String phone,
    required String email,
    required String password,
    required String appFlavor,
  }) {
    return _supabase.auth.signUp(
      phone: phone,
      password: password,
      data: {
        'email': email,
        'app_flavor': appFlavor,
      },
    );
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) {
    return _supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> resendOtp({
    required String phone,
  }) async {
    await _supabase.auth.resend(
      type: OtpType.sms,
      phone: phone,
    );
  }

  Future<void> sendPasswordResetOtp({
    required String phone,
  }) async {
    await _supabase.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: false,
    );
  }

  Future<AuthResponse> verifyPasswordResetOtp({
    required String phone,
    required String token,
  }) {
    return _supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> updatePassword({
    required String password,
  }) async {
    await _supabase.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );
  }

  Future<AuthResponse> signIn({
    required String phone,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  Future<void> signInWithGoogle({
    required String redirectTo,
  }) async {
    final launched = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw const AuthException(
        'Unable to start Google Sign-In.',
      );
    }
  }

  Future<void> updatePhone({
    required String phone,
  }) async {
    await _supabase.auth.updateUser(
      UserAttributes(
        phone: phone,
      ),
    );
  }

  Future<AuthResponse> verifyPhoneChangeOtp({
    required String phone,
    required String token,
  }) {
    return _supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.phoneChange,
    );
  }

  Future<void> signOut() {
    return _supabase.auth.signOut(
      scope: SignOutScope.local,
    );
  }
}