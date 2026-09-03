import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/pages/profile_details_page.dart';
import '../config/app_config.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({
    required AppConfig config,
    required Stream<AuthUser?> authStateChanges,
    required AuthUser? Function() currentUser,
    required ProfileRepository profileRepository,
  }) {
    final refreshListenable = _AuthRouterRefreshListenable(
      authStateChanges,
    );

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: refreshListenable,

      redirect: (context, state) async {
        final location = state.matchedLocation;

        final isSplash = location == '/splash';
        final isLogin = location == '/login';
        final isSignup = location == '/signup';
        final isOtp = location == '/otp';
        final isProfileDetails = location == '/profile-details';

        final user = currentUser();
        final isAuthenticated = user != null;

        // ============================================================
        // SPLASH
        // ============================================================
        //
        // SplashPage handles the initial authentication/profile check.
        //
        if (isSplash) {
          return null;
        }

        // ============================================================
        // NOT AUTHENTICATED
        // ============================================================
        //
        // Unauthenticated users can access:
        // - Login
        // - Signup
        // - OTP
        //
        // Everything else requires authentication.
        //
        if (!isAuthenticated) {
          if (isLogin || isSignup || isOtp) {
            return null;
          }

          return '/login';
        }

        // ============================================================
        // OTP
        // ============================================================
        //
        // OTP can be used for:
        //
        // 1. Phone signup verification
        // 2. Google user's phone verification
        //
        // Therefore, an authenticated user must be allowed to
        // access the OTP page.
        //
        if (isOtp) {
          return null;
        }

        // ============================================================
        // PROFILE DETAILS
        // ============================================================
        //
        // An authenticated user without the required role profile
        // must be allowed to complete Profile Details.
        //
        if (isProfileDetails) {
          return null;
        }

        // ============================================================
        // AUTHENTICATED USER ON LOGIN / SIGNUP
        // ============================================================
        //
        // This can happen after OAuth authentication or if an already
        // authenticated user manually navigates to Login/Signup.
        //
        // Check whether the required Worker/Employer profile exists.
        //
        if (isLogin || isSignup) {
          final hasProfile = await _hasRequiredProfile(
            config: config,
            profileRepository: profileRepository,
          );

          if (hasProfile) {
            return _homeLocation(config);
          }

          return '/profile-details';
        }

        // ============================================================
        // PROTECTED APPLICATION ROUTES
        // ============================================================
        //
        // Every authenticated application route requires the
        // role-specific profile.
        //
        final hasProfile = await _hasRequiredProfile(
          config: config,
          profileRepository: profileRepository,
        );

        if (!hasProfile) {
          return '/profile-details';
        }

        // ============================================================
        // FLAVOR PROTECTION
        // ============================================================
        //
        // Worker flavor cannot access Employer routes.
        //
        if (location.startsWith('/worker/') && !config.isWorker) {
          return _homeLocation(config);
        }

        // Employer flavor cannot access Worker routes.
        //
        if (location.startsWith('/employer/') && !config.isEmployer) {
          return _homeLocation(config);
        }

        return null;
      },

      // ============================================================
      // ROUTES
      // ============================================================

      routes: [
        // ==========================================================
        // AUTHENTICATION
        // ==========================================================

        GoRoute(
          path: '/splash',
          name: RouteNames.splash,
          builder: (context, state) {
            return const SplashPage();
          },
        ),

        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) {
            return const LoginPage();
          },
        ),

        GoRoute(
          path: '/signup',
          builder: (context, state) {
            return const SignupPage();
          },
        ),

        // ==========================================================
        // OTP
        // ==========================================================

        GoRoute(
          path: '/otp',
          name: RouteNames.otp,
          builder: (context, state) {
            final request = state.extra as OtpVerificationArgs?;

            if (request == null || request.phone.isEmpty) {
              return const _PlaceholderPage(
                title: 'Invalid OTP Request',
              );
            }

            return OtpPage(
              request: request,
            );
          },
        ),

        // ==========================================================
        // PROFILE DETAILS
        // ==========================================================

        GoRoute(
          path: '/profile-details',
          builder: (context, state) {
            return const ProfileDetailsPage();
          },
        ),

        // ==========================================================
        // WORKER
        // ==========================================================

        GoRoute(
          path: '/worker/home',
          name: RouteNames.workerHome,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Worker Home',
            );
          },
        ),

        GoRoute(
          path: '/worker/jobs',
          name: RouteNames.workerJobs,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Worker Jobs',
            );
          },
        ),

        GoRoute(
          path: '/worker/profile',
          name: RouteNames.workerProfile,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Worker Profile',
            );
          },
        ),

        GoRoute(
          path: '/worker/earnings',
          name: RouteNames.workerEarnings,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Worker Earnings',
            );
          },
        ),

        GoRoute(
          path: '/worker/availability',
          name: RouteNames.workerAvailability,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Worker Availability',
            );
          },
        ),

        GoRoute(
          path: '/worker/notifications',
          name: RouteNames.workerNotifications,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Worker Notifications',
            );
          },
        ),

        // ==========================================================
        // EMPLOYER
        // ==========================================================

        GoRoute(
          path: '/employer/home',
          name: RouteNames.employerHome,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Employer Home',
            );
          },
        ),

        GoRoute(
          path: '/employer/jobs',
          name: RouteNames.employerJobs,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Employer Jobs',
            );
          },
        ),

        GoRoute(
          path: '/employer/post-job',
          name: RouteNames.employerPostJob,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Post Job',
            );
          },
        ),

        GoRoute(
          path: '/employer/workers',
          name: RouteNames.employerWorkers,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Employer Workers',
            );
          },
        ),

        GoRoute(
          path: '/employer/payments',
          name: RouteNames.employerPayments,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Employer Payments',
            );
          },
        ),

        GoRoute(
          path: '/employer/profile',
          name: RouteNames.employerProfile,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Employer Profile',
            );
          },
        ),

        GoRoute(
          path: '/employer/notifications',
          name: RouteNames.employerNotifications,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Employer Notifications',
            );
          },
        ),
      ],
    );
  }

  // ================================================================
  // PROFILE CHECK
  // ================================================================

  static Future<bool> _hasRequiredProfile({
    required AppConfig config,
    required ProfileRepository profileRepository,
  }) async {
    if (config.isWorker) {
      return profileRepository.hasWorkerProfile();
    }

    return profileRepository.hasEmployerProfile();
  }

  // ================================================================
  // HOME LOCATION
  // ================================================================

  static String _homeLocation(AppConfig config) {
    if (config.isWorker) {
      return '/worker/home';
    }

    return '/employer/home';
  }
}

// ==================================================================
// AUTHENTICATION ROUTER REFRESH
// ==================================================================

class _AuthRouterRefreshListenable extends ChangeNotifier {
  _AuthRouterRefreshListenable(
    Stream<AuthUser?> authStateChanges,
  ) {
    _subscription = authStateChanges.listen(
      (_) {
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<AuthUser?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ==================================================================
// TEMPORARY PLACEHOLDER PAGE
// ==================================================================

class _PlaceholderPage extends ConsumerWidget {
  const _PlaceholderPage({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: primaryColor,
                  ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(signOutProvider)();
              },
              child: const Text('Temporary Logout'),
            ),
          ],
        ),
      ),
    );
  }
}