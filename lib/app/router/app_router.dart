import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/profile_details_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../config/app_config.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({
    required AppConfig config,
    required Stream<AuthUser?> authStateChanges,
    required AuthUser? Function() currentUser,
  }) {
    final refreshListenable = _AuthRouterRefreshListenable(
      authStateChanges,
    );

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: refreshListenable,

      redirect: (context, state) {
        final location = state.matchedLocation;

        final isSplash = location == '/splash';
        final isLogin = location == '/login';
        final isSignup = location == '/signup';
        final isOtp = location == '/otp';

        final user = currentUser();
        final isAuthenticated = user != null;

        // ======================================================
        // Splash
        // ======================================================
        //
        // SplashPage is responsible for the initial
        // authentication decision.
        //
        if (isSplash) {
          return null;
        }

        // ======================================================
        // Public Authentication Routes
        // ======================================================

        final isAuthRoute =
            isLogin ||
            isSignup ||
            isOtp;

        if (isAuthRoute) {
          return null;
        }

        // ======================================================
        // Protected Routes
        // ======================================================

        if (!isAuthenticated) {
          return '/login';
        }

        // ======================================================
        // Flavor Protection
        // ======================================================

        if (location.startsWith('/worker/') && !config.isWorker) {
          return _homeLocation(config);
        }

        if (location.startsWith('/employer/') && !config.isEmployer) {
          return _homeLocation(config);
        }

        return null;
      },

      routes: [
        // ======================================================
        // Authentication
        // ======================================================

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

        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final phone = state.extra as String?;

            if (phone == null || phone.isEmpty) {
              return const _PlaceholderPage(
                title: 'Invalid OTP Request',
              );
            }

            return OtpPage(
              phone: phone,
            );
          },
        ),

        GoRoute(
          path: '/profile-details',
          builder: (context, state) {
            return const ProfileDetailsPage();
          },
        ),

        // ======================================================
        // Worker
        // ======================================================

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

        // ======================================================
        // Employer
        // ======================================================

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

  // ============================================================
  // Home Location
  // ============================================================

  static String _homeLocation(AppConfig config) {
    if (config.isWorker) {
      return '/worker/home';
    }

    return '/employer/home';
  }
}

// ================================================================
// Authentication Router Refresh
// ================================================================

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

// ================================================================
// Temporary Placeholder Page
// ================================================================

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: primaryColor,
              ),
        ),
      ),
    );
  }
}