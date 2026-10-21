import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/network_status_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/network_status_views.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';

class PatchBroApp extends ConsumerStatefulWidget {
  const PatchBroApp({super.key, required this.config});

  final AppConfig config;

  @override
  ConsumerState<PatchBroApp> createState() => _PatchBroAppState();
}

class _PatchBroAppState extends ConsumerState<PatchBroApp> {
  late final GoRouter _appRouter;

  // This remains false for an offline launch. Once the app has started while
  // online, later outages keep the current route visible and show a banner.
  bool _hasStartedOnline = false;

  @override
  void initState() {
    super.initState();

    final authRepository = ref.read(authRepositoryProvider);

    final profileRepository = ref.read(profileRepositoryProvider);

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
    final theme = AppTheme.fromFlavor(widget.config.flavor);
    final connectionStatus = ref.watch(networkConnectionStatusProvider);

    return connectionStatus.when(
      loading: () =>
          _statusApp(theme: theme, child: const _CheckingNetworkScreen()),
      error: (_, _) => _offlineApp(theme),
      data: (status) {
        if (status == NetworkConnectionStatus.online) {
          _hasStartedOnline = true;
        }

        if (!_hasStartedOnline) {
          return _offlineApp(theme);
        }

        final isOffline = status == NetworkConnectionStatus.offline;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: widget.config.appName,
          theme: theme,
          routerConfig: _appRouter,
          builder: (context, child) {
            return Column(
              children: [
                if (isOffline) const NoNetworkBanner(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
        );
      },
    );
  }

  MaterialApp _offlineApp(ThemeData theme) {
    return _statusApp(
      theme: theme,
      child: NetworkErrorScreen(
        onRetry: () => ref.invalidate(networkConnectionStatusProvider),
      ),
    );
  }

  MaterialApp _statusApp({required ThemeData theme, required Widget child}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: widget.config.appName,
      theme: theme,
      home: child,
    );
  }
}

class _CheckingNetworkScreen extends StatelessWidget {
  const _CheckingNetworkScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
