import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';

import '../widgets/app_bottom_nav_bar.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.resetsPostJobSession = false,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppBottomNavDestination> destinations;
  final bool resetsPostJobSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          // The Post Job branch is kept in the indexed shell. Begin a fresh
          // form when it is entered so a cancelled/submitted draft cannot be
          // exposed when the employer comes back later.
          if (resetsPostJobSession && index == 2) {
            ref.read(postJobControllerProvider.notifier).startCreateSession();
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
