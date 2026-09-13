import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/employer/profile/presentation/providers/employer_profile_providers.dart';
import 'package:patch_bro/features/employer/profile/presentation/widgets/switch_to_worker_card.dart';

import '../../domain/entities/employer_profile_entity.dart';
import '../widgets/employer_profile_menu_tile.dart';
import '../widgets/employer_profile_section.dart';

class EmployerSettingsAndSupportPage extends ConsumerWidget {
  const EmployerSettingsAndSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings And Support'),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(employerProfileControllerProvider).profile;

    // ============================================================
    // Temporary Action
    // ============================================================

    void showComingSoon(String feature) {
      AppSnackbar.info(context, '$feature will be available soon.');
    }

    void onPersonalInformation() {
      context.pushNamed(RouteNames.employerPersonalInformation);
    }

    void onAddresses() {
      showComingSoon('Addresses');
    }

    void onNotifications() {
      context.pushNamed(RouteNames.employerNotifications);
    }

    void onSecurity() {
      showComingSoon('Security & Privacy');
    }

    void onSwitchToWorker() {
      showComingSoon('Switch to Worker');
    }

    void onHelp() {
      showComingSoon('Help & Support');
    }

    void onTerms() {
      showComingSoon('Terms & Conditions');
    }

    void onPrivacy() {
      showComingSoon('Privacy Policy');
    }

    // ============================================================
    // Logout
    // ============================================================

    Future<void> onLogout() async {
      final confirmed = await AppDialog.confirm(
        context,
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        confirmLabel: 'Logout',
        cancelLabel: 'Cancel',
        icon: Icons.logout_rounded,
      );

      if (confirmed == true || !context.mounted) {
        return;
      }

      try {
        await ref.read(signOutProvider)();

        if (!context.mounted) {
          return;
        }

        AppSnackbar.success(context, 'Logged out successfully.');
      } catch (_) {
        if (!context.mounted) {
          return;
        }

        AppSnackbar.error(context, 'Unable to logout. Please try again.');
      }
    }

    return _SettingsContent(
      onAddresses: onAddresses,
      onHelp: onHelp,
      profile: profile,
      onPersonalInformation: onPersonalInformation,
      onNotifications: onNotifications,
      onSecurity: onSecurity,
      onSwitchToWorker: onSwitchToWorker,
      onTerms: onTerms,
      onPrivacy: onPrivacy,
      onLogout: onLogout,
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    this.profile,
    required this.onPersonalInformation,
    required this.onAddresses,
    required this.onNotifications,
    required this.onSecurity,
    required this.onSwitchToWorker,
    required this.onHelp,
    required this.onTerms,
    required this.onPrivacy,
    required this.onLogout,
  });

  final EmployerProfileEntity? profile;

  final VoidCallback onPersonalInformation;
  final VoidCallback onAddresses;

  final VoidCallback onNotifications;
  final VoidCallback onSecurity;

  final VoidCallback onSwitchToWorker;

  final VoidCallback onHelp;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 32),
          children: [
            EmployerProfileSection(
              title: 'Personal',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  onTap: onPersonalInformation,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Addresses',
                  onTap: onAddresses,
                ),
              ],
            ),

            const SizedBox(height: 18),

            EmployerProfileSection(
              title: 'Preferences',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: onNotifications,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Security & Privacy',
                  onTap: onSecurity,
                ),
              ],
            ),

            if (profile?.hasWorkerProfile == true) ...[
              const SizedBox(height: 18),
              SwitchToWorkerCard(onTap: onSwitchToWorker),
            ],

            const SizedBox(height: 18),

            EmployerProfileSection(
              title: 'Support',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: onHelp,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: onTerms,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: onPrivacy,
                ),
              ],
            ),

            const SizedBox(height: 18),

            EmployerProfileSection(
              title: '',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: onLogout,
                  isDestructive: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
