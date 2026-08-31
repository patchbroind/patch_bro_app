import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
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

  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();

    ref.listenManual<AsyncValue<AuthUser?>>(
      authStateProvider,
      (_, next) {
        next.when(
          data: (user) {
            _authStateResolved = true;
            _isAuthenticated = user != null;

            _tryNavigate();
          },
          loading: () {
            // Keep showing the splash screen.
          },
          error: (_, _) {
            _authStateResolved = true;
            _isAuthenticated = false;

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

  void _tryNavigate() {
    if (!mounted ||
        _hasNavigated ||
        !_minimumDurationCompleted ||
        !_authStateResolved ||
        _isAuthenticated == null) {
      return;
    }

    _hasNavigated = true;

    final config = ref.read(appConfigProvider);

    if (_isAuthenticated!) {
      context.go(
        _homeLocation(config),
      );
    } else {
      context.goNamed(
        RouteNames.login,
      );
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