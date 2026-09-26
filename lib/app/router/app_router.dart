import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/employer/addresses/presentation/pages/employer_addresses_page.dart';
import 'package:patch_bro/features/employer/benefit/presentation/pages/employer_benefit_page.dart';
import 'package:patch_bro/features/employer/favourite_workers/presentation/pages/employer_favourite_workers_page.dart';
import 'package:patch_bro/features/employer/home/presentation/pages/employer_home_page.dart';
import 'package:patch_bro/features/employer/jobs/presentation/pages/employer_jobs_page.dart';
import 'package:patch_bro/features/employer/post_job/presentation/pages/employer_post_job_page.dart';
import 'package:patch_bro/features/employer/profile/presentation/pages/employer_personal_information_page.dart';
import 'package:patch_bro/features/employer/profile/presentation/pages/employer_profile_page.dart';
import 'package:patch_bro/features/employer/profile/presentation/pages/employer_settings_and_support.dart';
import 'package:patch_bro/features/employer/trust/presentation/pages/employer_trust_page.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/pages/employer_invite_workers_page.dart';
import 'package:patch_bro/features/employer/workers/presentation/pages/employer_worker_details_page.dart';
import 'package:patch_bro/features/employer/workers/presentation/pages/employer_workers_page.dart';
import 'package:patch_bro/features/navigation/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:patch_bro/features/notifications/presentation/pages/notifications_page.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitation_realtime_listener.dart';
import 'package:patch_bro/features/worker/profile/presentation/pages/worker_profile_page.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';

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

      // ============================================================
      // ROUTER REDIRECT
      // ============================================================
      redirect: (context, state) async {
        final location = state.matchedLocation;

        // ==========================================================
        // PUBLIC / AUTH ROUTES
        // ==========================================================

        final isSplash = location == '/splash';

        final isLogin = location == '/login';

        final isSignup = location == '/signup';

        final isForgotPassword = location == '/forgot-password';

        final isResetPassword = location == '/reset-password';

        final isOtp = location == '/otp';

        final isProfileDetails = location == '/profile-details';

        // ==========================================================
        // WORKER PROFILE SETUP
        //
        // This route is intentionally allowed before a worker
        // profile exists.
        //
        // The worker has already completed the basic profile
        // details, but still needs to create the professional
        // worker profile.
        // ==========================================================

        final isWorkerProfileSetup = location == '/worker/profile/setup';

        final user = currentUser();

        final isAuthenticated = user != null;

        // ==========================================================
        // SPLASH
        // ==========================================================

        if (isSplash) {
          return null;
        }

        // ==========================================================
        // NOT AUTHENTICATED
        // ==========================================================

        if (!isAuthenticated) {
          if (isLogin || isSignup || isForgotPassword || isResetPassword || isOtp) {
            return null;
          }

          return '/login';
        }

        // ==========================================================
        // OTP
        // ==========================================================

        if (isOtp) {
          return null;
        }

        // ==========================================================
        // PASSWORD RECOVERY
        // ==========================================================

        if (isForgotPassword || isResetPassword) {
          return null;
        }

        // ==========================================================
        // BASIC PROFILE DETAILS
        //
        // This page is allowed before the required role-specific
        // profile exists.
        // ==========================================================

        if (isProfileDetails) {
          return null;
        }

        // ==========================================================
        // WORKER PROFILE SETUP
        //
        // IMPORTANT:
        //
        // A Worker is allowed to enter this route even when
        // worker_profiles does not yet contain a row.
        //
        // Employer users are redirected to their own home.
        // ==========================================================

        if (isWorkerProfileSetup) {
          if (!config.isWorker) {
            return _homeLocation(config);
          }

          return null;
        }

        // ==========================================================
        // AUTHENTICATED USER ON LOGIN / SIGNUP
        // ==========================================================

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

        // ==========================================================
        // PROTECTED APPLICATION ROUTES
        // ==========================================================

        final hasProfile = await _hasRequiredProfile(
          config: config,
          profileRepository: profileRepository,
        );

        if (!hasProfile) {
          return '/profile-details';
        }

        // ==========================================================
        // WORKER / EMPLOYER ROLE PROTECTION
        // ==========================================================

        if (location.startsWith('/worker/') && !config.isWorker) {
          return _homeLocation(config);
        }

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
        // SPLASH
        // ==========================================================

        GoRoute(
          path: '/splash',
          name: RouteNames.splash,
          builder: (context, state) {
            return const SplashPage();
          },
        ),

        // ==========================================================
        // LOGIN
        // ==========================================================
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) {
            return const LoginPage();
          },
        ),

        // ==========================================================
        // SIGNUP
        // ==========================================================
        GoRoute(
          path: '/signup',
          name: RouteNames.signup,
          builder: (context, state) {
            return const SignupPage();
          },
        ),

        // ==========================================================
        // FORGOT PASSWORD
        // ==========================================================
        GoRoute(
          path: '/forgot-password',
          name: RouteNames.forgotPassword,
          builder: (context, state) {
            return const ForgotPasswordPage();
          },
        ),

        // ==========================================================
        // RESET PASSWORD
        // ==========================================================
        GoRoute(
          path: '/reset-password',
          name: RouteNames.resetPassword,
          builder: (context, state) {
            return const ResetPasswordPage();
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
              return const _PlaceholderPage(title: 'Invalid OTP Request');
            }

            return OtpPage(request: request);
          },
        ),

        // ==========================================================
        // PROFILE DETAILS
        // ==========================================================
        GoRoute(
          path: '/profile-details',
          name: RouteNames.profileDetails,
          builder: (context, state) {
            return const ProfileDetailsPage();
          },
        ),

        // ==========================================================
        // WORKER PROFILE SETUP
        //
        // IMPORTANT:
        //
        // This is intentionally OUTSIDE the Worker shell.
        //
        // Reason:
        // The setup screen is an onboarding screen and should NOT
        // display the Worker bottom navigation bar.
        //
        // It is also allowed before worker_profiles exists.
        // ==========================================================
        GoRoute(
          path: '/worker/profile/setup',
          name: RouteNames.workerProfileSetup,
          builder: (context, state) {
            return const WorkerProfilePage(isSetup: true);
          },
        ),

        // ==========================================================
        // EMPLOYER TRUST
        // ==========================================================
        GoRoute(
          path: '/employer/trust',
          name: RouteNames.employerTrust,
          builder: (context, state) {
            return const EmployerTrustPage();
          },
        ),

        // ==========================================================
        // EMPLOYER BENEFIT
        // ==========================================================
        GoRoute(
          path: '/employer/benefit',
          name: RouteNames.employerBenefit,
          builder: (context, state) {
            return const EmployerBenefitPage();
          },
        ),

        // ==========================================================
        // EMPLOYER FAVOURITE WORKERS
        // ==========================================================
        GoRoute(
          path: '/employer/favourite-workers',
          name: RouteNames.employerFavouriteWorkers,
          builder: (context, state) {
            return const EmployerFavouriteWorkersPage();
          },
        ),

        // ==========================================================
        // EMPLOYER PERSONAL INFORMATION
        // ==========================================================
        GoRoute(
          path: '/employer/personal-information',
          name: RouteNames.employerPersonalInformation,
          builder: (context, state) {
            return const EmployerPersonalInformationPage();
          },
        ),

        // ==========================================================
        // EMPLOYER ADDRESSES
        // ==========================================================
        GoRoute(
          path: '/employer/addresses',
          name: RouteNames.employerAddresses,
          builder: (context, state) {
            return const EmployerAddressesPage();
          },
        ),

        // ==========================================================
        // EMPLOYER SETTINGS
        // ==========================================================
        GoRoute(
          path: '/employer/settings',
          name: RouteNames.employerSettings,
          builder: (context, state) {
            return const EmployerSettingsAndSupportPage();
          },
        ),

        // ==========================================================
        // EMPLOYER NOTIFICATIONS
        // ==========================================================
        GoRoute(
          path: '/employer/notifications',
          name: RouteNames.employerNotifications,
          builder: (context, state) {
            return const NotificationsPage();
          },
        ),

        // ==========================================================
        // EMPLOYER WORKER PROFILE
        //
        // This is intentionally outside the Employer shell.
        //
        // It is opened from the Workers screen using:
        //
        // context.pushNamed(
        //   RouteNames.employerWorkerProfile,
        //   extra: workerId,
        // );
        // ==========================================================
        GoRoute(
          path: '/employer/worker-profile',
          name: RouteNames.employerWorkerProfile,
          builder: (context, state) {
            final workerId = state.extra as String?;

            if (workerId == null || workerId.isEmpty) {
              return const _PlaceholderPage(title: 'Invalid Worker');
            }

            return EmployerWorkerDetailsPage(workerId: workerId);
          },
        ),

        GoRoute(
  path: '/employer/edit-job',
  name: RouteNames.employerEditJob,
  builder: (context, state) {
    final job = state.extra as EmployerJobEntity?;

    if (job == null) {
      return const _PlaceholderPage(title: 'Invalid Job');
    }

    return EmployerPostJobPage(job: job);
  },
),

        GoRoute(
          path: '/employer/invite-workers',
          name: RouteNames.employerInviteWorkers,
          builder: (context, state) {
            final jobId = state.uri.queryParameters['jobId'];

            if (jobId == null || jobId.isEmpty) {
              return const _PlaceholderPage(title: 'Invalid Job');
            }

            return EmployerInviteWorkersPage(
              jobId: jobId,
              category: state.uri.queryParameters['category'],
              skill: state.uri.queryParameters['skill'],
            );
          },
        ),

        // ==========================================================
        // WORKER SHELL
        // ==========================================================
        if (config.isWorker) _buildWorkerShell(),

        // ==========================================================
        // EMPLOYER SHELL
        // ==========================================================
        if (config.isEmployer) _buildEmployerShell(),
      ],
    );
  }

  // ==============================================================
  // WORKER SHELL
  // ==============================================================

  static StatefulShellRoute _buildWorkerShell() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return WorkerInvitationRealtimeListener(
          child: MainNavigationPage(
            navigationShell: navigationShell,
            destinations: const [
              AppBottomNavDestination(icon: Icons.home_outlined, label: 'Home'),
              AppBottomNavDestination(icon: Icons.search, label: 'Explore'),
              AppBottomNavDestination(icon: Icons.access_time_outlined, label: 'Availability'),
              AppBottomNavDestination(icon: Icons.book, label: 'Booking'),
              AppBottomNavDestination(icon: Icons.person_outline, label: 'Profile'),
            ],
          ),
        );
      },
      branches: [
        // ==========================================================
        // WORKER HOME
        // ==========================================================

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

        // ==========================================================
        // WORKER JOBS
        // ==========================================================
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

        // ==========================================================
        // WORKER AVAILABILITY
        // ==========================================================
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

        // ==========================================================
        // WORKER EARNINGS
        // ==========================================================
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

        // ==========================================================
        // WORKER PROFILE
        //
        // This is the actual Worker Profile page after the
        // professional profile has been created.
        // ==============================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/profile',
              name: RouteNames.workerProfile,
              builder: (context, state) {
                return const WorkerProfilePage();
              },
            ),
          ],
        ),
      ],
    );
  }

  // ==============================================================
  // EMPLOYER SHELL
  // ==============================================================

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
        // ==========================================================
        // EMPLOYER HOME
        // ==========================================================

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

        // ==========================================================
        // EMPLOYER JOBS
        // ==========================================================
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

        // ==========================================================
        // EMPLOYER POST JOB
        // ==========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/post-job',
              name: RouteNames.employerPostJob,
              builder: (context, state) {
                return const EmployerPostJobPage();
              },
            ),
          ],
        ),

        // ==========================================================
        // EMPLOYER WORKERS
        // ==========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/workers',
              name: RouteNames.employerWorkers,
              builder: (context, state) {
                final tab = state.uri.queryParameters['tab'];

                final initialTab = tab == 'favourites'
                    ? EmployerWorkersTab.favourites
                    : EmployerWorkersTab.workers;

                return EmployerWorkersPage(
                  key: ValueKey(state.uri.toString()),
                  initialTab: initialTab,
                );
              },
            ),
          ],
        ),

        // ==========================================================
        // EMPLOYER PROFILE
        // ==========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employer/profile',
              name: RouteNames.employerProfile,
              builder: (context, state) {
                return const EmployerProfilePage();
              },
            ),
          ],
        ),
      ],
    );
  }

  // ==============================================================
  // PROFILE CHECK
  // ==============================================================

  static Future<bool> _hasRequiredProfile({
    required AppConfig config,
    required ProfileRepository profileRepository,
  }) async {
    if (config.isWorker) {
      return profileRepository.hasWorkerProfile();
    }

    return profileRepository.hasEmployerProfile();
  }

  // ==============================================================
  // HOME LOCATION
  // ==============================================================

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

// ==================================================================
// TEMPORARY PLACEHOLDER PAGE
// ==================================================================

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
