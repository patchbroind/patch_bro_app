import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({
    required AppConfig config,
  }) {
    return GoRouter(
      initialLocation: _initialLocation(config),
      routes: [
        // ========================================================
        // Authentication
        // ========================================================

        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) {
            return const _PlaceholderPage(
              title: 'Login',
            );
          },
        ),

        // ========================================================
        // Worker
        // ========================================================

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

        // ========================================================
        // Employer
        // ========================================================

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

  static String _initialLocation(AppConfig config) {
    if (config.isWorker) {
      return '/worker/home';
    }

    return '/employer/home';
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}