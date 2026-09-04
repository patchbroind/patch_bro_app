import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({
    super.key,
  });

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static const _minimumSplashDuration = Duration(seconds: 2);

  Timer? _timer;

  bool _minimumDurationCompleted = false;
  bool _authStateResolved = false;
  bool _hasNavigated = false;

  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();

    ref.listenManual<AsyncValue<AuthUser?>>(
      authStateProvider,
      (_, next) {
        next.when(
          data: (user) {
            _authStateResolved = true;
            _currentUser = user;

            _tryNavigate();
          },
          loading: () {
            // Keep showing splash.
          },
          error: (_, _) {
            _authStateResolved = true;
            _currentUser = null;

            _tryNavigate();
          },
        );
      },
      fireImmediately: true,
    );

    _startMinimumSplashTimer();
  }

  void _startMinimumSplashTimer() {
    _timer = Timer(
      _minimumSplashDuration,
      () {
        if (!mounted) {
          return;
        }

        _minimumDurationCompleted = true;

        _tryNavigate();
      },
    );
  }

  Future<void> _tryNavigate() async {
    if (!mounted ||
        _hasNavigated ||
        !_minimumDurationCompleted ||
        !_authStateResolved) {
      return;
    }

    _hasNavigated = true;

    final config = ref.read(appConfigProvider);

    // User is not authenticated.
    if (_currentUser == null) {
      if (!mounted) return;

      context.goNamed(
        RouteNames.login,
      );

      return;
    }

    try {
      final profileRepository = ref.read(
        profileRepositoryProvider,
      );

      final hasProfile = config.isWorker
          ? await profileRepository.hasWorkerProfile()
          : await profileRepository.hasEmployerProfile();

      if (!mounted) return;

      if (hasProfile) {
        context.go(
          _homeLocation(config),
        );
      } else {
        context.go('/profile-details');
      }
    } catch (error) {
      if (!mounted) return;

      // If the profile check fails, don't incorrectly send the
      // authenticated user to Home. Resume profile completion.
      context.go('/profile-details');
    }
  }

  String _homeLocation(AppConfig config) {
    if (config.isWorker) {
      return '/worker/home';
    }

    return '/employer/home';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              AppColors.black,
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'PATCH BRO',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}