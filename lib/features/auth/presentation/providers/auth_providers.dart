import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../../app/config/app_config.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/resend_otp.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/verify_otp.dart';
import '../controllers/auth_controller.dart';

// App Configuration........................

final appConfigProvider = Provider<AppConfig>(
  (ref) {
    return AppConfig.fromEnvironment();
  },
);

// Supabase.................................

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) {
    return Supabase.instance.client;
  },
);

// Data Source..............................

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) {
    return AuthRemoteDataSource(
      ref.read(supabaseClientProvider),
    );
  },
);

// Repository..............................

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepositoryImpl(
      ref.read(authRemoteDataSourceProvider),
    );
  },
);

// Use Cases.................................

final signUpProvider = Provider<SignUp>(
  (ref) {
    return SignUp(
      ref.read(authRepositoryProvider),
    );
  },
);

final verifyOtpProvider = Provider<VerifyOtp>(
  (ref) {
    return VerifyOtp(
      ref.read(authRepositoryProvider),
    );
  },
);

final resendOtpProvider = Provider<ResendOtp>(
  (ref) {
    return ResendOtp(
      ref.read(authRepositoryProvider),
    );
  },
);

final signInProvider = Provider<SignIn>(
  (ref) {
    return SignIn(
      ref.read(authRepositoryProvider),
    );
  },
);

final signOutProvider = Provider<SignOut>(
  (ref) {
    return SignOut(
      ref.read(authRepositoryProvider),
    );
  },
);

// Authentication State............................

final authStateProvider = StreamProvider<AuthUser?>(
  (ref) {
    return ref
        .watch(authRepositoryProvider)
        .authStateChanges;
  },
);

// Current Authenticated User.......................

final currentUserProvider = Provider<AuthUser?>(
  (ref) {
    final authState = ref.watch(authStateProvider);

    return authState.whenOrNull(
      data: (user) => user,
    );
  },
);

// Authentication Controller...........................

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);