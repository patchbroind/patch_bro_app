import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';

class PatchBroApp extends ConsumerStatefulWidget {
  const PatchBroApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  ConsumerState<PatchBroApp> createState() => _PatchBroAppState();
}

class _PatchBroAppState extends ConsumerState<PatchBroApp> {
  late final GoRouter _appRouter;

  @override
  void initState() {
    super.initState();

    final authRepository = ref.read(
      authRepositoryProvider,
    );

    final profileRepository = ref.read(
      profileRepositoryProvider,
    );

    _appRouter = AppRouter.create(
      config: widget.config,
      authStateChanges: authRepository.authStateChanges,
      currentUser: () => authRepository.currentUser,
      profileRepository: profileRepository,
    );
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: widget.config.appName,
      theme: AppTheme.fromFlavor(
        widget.config.flavor,
      ),
      routerConfig: _appRouter,
    );
  }
}