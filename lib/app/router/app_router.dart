import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/employer/home/presentation/pages/employer_home_page.dart';
import 'package:patch_bro/features/employer/jobs/presentation/pages/employer_jobs_page.dart';
import 'package:patch_bro/features/navigation/presentation/widgets/app_bottom_nav_bar.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
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
    final refreshListenable = _AuthRouterRefreshListenable(authStateChanges);

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: refreshListenable,

      redirect: (context, state) async {
        final location = state.matchedLocation;

        final isSplash = location == '/splash';
        final isLogin = location == '/login';
        final isSignup = location == '/signup';
        final isForgotPassword = location == '/forgot-password';
        final isResetPassword = location == '/reset-password';
        final isOtp = location == '/otp';
        final isProfileDetails = location == '/profile-details';

        final user = currentUser();
        final isAuthenticated = user != null;

        // SPLASH

        if (isSplash) {
          return null;
        }

        // NOT AUTHENTICATED

        if (!isAuthenticated) {
          if (isLogin || isSignup || isForgotPassword || isResetPassword || isOtp) {
            return null;
          }

          return '/login';
        }

        // OTP

        if (isOtp) {
          return null;
        }

        // PASSWORD RECOVERY

        if (isForgotPassword || isResetPassword) {
          return null;
        }

        // PROFILE DETAILS

        if (isProfileDetails) {
          return null;
        }

        // AUTHENTICATED USER ON LOGIN / SIGNUP

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

        // PROTECTED APPLICATION ROUTES

        final hasProfile = await _hasRequiredProfile(
          config: config,
          profileRepository: profileRepository,
        );

        if (!hasProfile) {
          return '/profile-details';
        }

        if (location.startsWith('/worker/') && !config.isWorker) {
          return _homeLocation(config);
        }

        if (location.startsWith('/employer/') && !config.isEmployer) {
          return _homeLocation(config);
        }

        return null;
      },

      routes: [
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
          name: RouteNames.signup,
          builder: (context, state) {
            return const SignupPage();
          },
        ),

        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) {
            return const ForgotPasswordPage();
          },
        ),

        GoRoute(
          path: '/reset-password',
          name: 'reset-password',
          builder: (context, state) {
            return const ResetPasswordPage();
          },
        ),

        GoRoute(
          path: '/otp',
          name: RouteNames.otp,
          builder: (context, state) {
            final request = state.extra as OtpVerificationArgs?;

            if (request == null || request.phone.isEmpty) {
              return const _PlaceholderPage(title: 'Invalid OTP Request');
            }

            return OtpPage(request: request);
          },
        ),

        GoRoute(
          path: '/profile-details',
          name: RouteNames.profileDetails,
          builder: (context, state) {
            return const ProfileDetailsPage();
          },
        ),

        if (config.isWorker) _buildWorkerShell(),

        if (config.isEmployer) _buildEmployerShell(),
      ],
    );
  }

  // WORKER SHELL

  static StatefulShellRoute _buildWorkerShell() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationPage(
          navigationShell: navigationShell,
          destinations: const [
            AppBottomNavDestination(icon: Icons.home_outlined, label: 'Home'),
            AppBottomNavDestination(icon: Icons.search, label: 'Explore'),
            AppBottomNavDestination(icon: Icons.access_time_outlined, label: 'Availability'),
            AppBottomNavDestination(icon: Icons.book, label: 'Booking'),
            AppBottomNavDestination(icon: Icons.person_outline, label: 'Profile'),
          ],
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/home',
              name: RouteNames.workerHome,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Worker Home');
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/jobs',
              name: RouteNames.workerJobs,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Worker Jobs');
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/availability',
              name: RouteNames.workerAvailability,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Worker Availability');
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/earnings',
              name: RouteNames.workerEarnings,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Worker Earnings');
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/profile',
              name: RouteNames.workerProfile,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Worker Profile');
              },
            ),
          ],
        ),
      ],
    );
  }

  // EMPLOYER SHELL

  static StatefulShellRoute _buildEmployerShell() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationPage(
          navigationShell: navigationShell,
          destinations: const [
            AppBottomNavDestination(icon: Icons.home_outlined, label: 'Home'),
            AppBottomNavDestination(icon: Icons.work_outline, label: 'Jobs'),
            AppBottomNavDestination(icon: Icons.add_circle_outline, label: 'Post Job'),
            AppBottomNavDestination(icon: Icons.people_outline, label: 'Workers'),
            AppBottomNavDestination(icon: Icons.person_outline, label: 'Profile'),
          ],
        );
      },

      branches: [
        // EMPLOYER HOME

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/home',
              name: RouteNames.employerHome,
              builder: (context, state) {
                return const EmployerHomePage();
              },
            ),
          ],
        ),

        // EMPLOYER JOBS
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/jobs',
              name: RouteNames.employerJobs,
              builder: (context, state) {
                return const EmployerJobsPage();
              },
            ),
          ],
        ),

        // EMPLOYER POST JOB
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/post-job',
              name: RouteNames.employerPostJob,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Post Job');
              },
            ),
          ],
        ),
        // EMPLOYER POST JOB
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/workers',
              name: RouteNames.employerWorkers,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Workers');
              },
            ),
          ],
        ),

        // EMPLOYER PROFILE
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/profile',
              name: RouteNames.employerProfile,
              builder: (context, state) {
                return const _PlaceholderPage(title: 'Employer Profile');
              },
            ),
          ],
        ),
      ],
    );
  }

  // PROFILE CHECK

  static Future<bool> _hasRequiredProfile({
    required AppConfig config,
    required ProfileRepository profileRepository,
  }) async {
    if (config.isWorker) {
      return profileRepository.hasWorkerProfile();
    }

    return profileRepository.hasEmployerProfile();
  }

  // HOME LOCATION

  static String _homeLocation(AppConfig config) {
    if (config.isWorker) {
      return '/worker/home';
    }

    return '/employer/home';
  }
}

// AUTHENTICATION ROUTER REFRESH

class _AuthRouterRefreshListenable extends ChangeNotifier {
  _AuthRouterRefreshListenable(Stream<AuthUser?> authStateChanges) {
    _subscription = authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthUser?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// TEMPORARY PLACEHOLDER PAGE

class _PlaceholderPage extends ConsumerWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: primaryColor),
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
