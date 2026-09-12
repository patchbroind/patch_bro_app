import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/employer/profile/presentation/widgets/switch_to_worker_card.dart';

import '../../domain/entities/employer_profile_entity.dart';
import '../controllers/employer_profile_state.dart';
import '../providers/employer_profile_providers.dart';
import '../widgets/employer_benefit_card.dart';
import '../widgets/employer_profile_header.dart';
import '../widgets/employer_profile_menu_tile.dart';
import '../widgets/employer_profile_section.dart';
import '../widgets/employer_profile_stats.dart';
import '../widgets/employer_trust_card.dart';

class EmployerProfilePage extends ConsumerStatefulWidget {
  const EmployerProfilePage({super.key});

  @override
  ConsumerState<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends ConsumerState<EmployerProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(employerProfileControllerProvider.notifier).loadProfile();
    });
  }

  Future<void> _refresh() {
    return ref.read(employerProfileControllerProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: _onSecurity,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerProfileState state) {
    if (state.isLoading && !state.hasProfile) {
      return const _ProfileLoadingView();
    }

    if (state.isFailure && !state.hasProfile) {
      return AppErrorView(
        title: 'Unable to load Profile',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: () {
          ref.read(employerProfileControllerProvider.notifier).loadProfile();
        },
      );
    }

    final profile = state.profile;

    if (profile == null) {
      return AppErrorView(
        title: 'Unable to load Profile',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: () {
          ref.read(employerProfileControllerProvider.notifier).loadProfile();
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _ProfileContent(
        profile: profile,
        onEditProfile: _onEditProfile,
        onTrustDetails: _onTrustDetails,
        onBenefitDetails: _onBenefitDetails,
        onMyJobs: _onMyJobs,
        onInvitations: _onInvitations,
        onFavouriteWorkers: _onFavouriteWorkers,
        onMyReviews: _onMyReviews,
        onPaymentHistory: _onPaymentHistory,
        onPersonalInformation: _onPersonalInformation,
        onAddresses: _onAddresses,
        onNotifications: _onNotifications,
        onSecurity: _onSecurity,
        onSwitchToWorker: _onSwitchToWorker,
        onHelp: _onHelp,
        onTerms: _onTerms,
        onPrivacy: _onPrivacy,
        onLogout: _onLogout,
      ),
    );
  }

  // ============================================================
  // Navigation / Actions
  // ============================================================

  void _onEditProfile() {
    _showComingSoon('Edit Profile');
  }

  void _onTrustDetails() {
    context.pushNamed(RouteNames.employerTrust);
  }

  void _onBenefitDetails() {
    context.pushNamed(RouteNames.employerBenefit);
  }

  void _onMyJobs() {
    context.goNamed(RouteNames.employerJobs);
  }

  void _onInvitations() {
    _showComingSoon('Invitations');
  }

  void _onFavouriteWorkers() {
    context.pushNamed(RouteNames.employerFavouriteWorkers);
  }

  void _onMyReviews() {
    _showComingSoon('My Reviews');
  }

  void _onPaymentHistory() {
    _showComingSoon('Payment History');
  }

  void _onPersonalInformation() {
    context.pushNamed(RouteNames.employerPersonalInformation);
  }

  void _onAddresses() {
    _showComingSoon('Addresses');
  }

  void _onNotifications() {
    context.pushNamed(RouteNames.employerNotifications);
  }

  void _onSecurity() {
    _showComingSoon('Security & Privacy');
  }

  void _onSwitchToWorker() {
    _showComingSoon('Switch to Worker');
  }

  void _onHelp() {
    _showComingSoon('Help & Support');
  }

  void _onTerms() {
    _showComingSoon('Terms & Conditions');
  }

  void _onPrivacy() {
    _showComingSoon('Privacy Policy');
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> _onLogout() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
      icon: Icons.logout_rounded,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(signOutProvider)();

      if (!mounted) {
        return;
      }

      AppSnackbar.success(context, 'Logged out successfully.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to logout. Please try again.');
    }
  }

  // ============================================================
  // Temporary Action
  // ============================================================

  void _showComingSoon(String feature) {
    AppSnackbar.info(context, '$feature will be available soon.');
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.onEditProfile,
    required this.onTrustDetails,
    required this.onBenefitDetails,
    required this.onMyJobs,
    required this.onInvitations,
    required this.onFavouriteWorkers,
    required this.onMyReviews,
    required this.onPaymentHistory,
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

  final EmployerProfileEntity profile;

  final VoidCallback onEditProfile;
  final VoidCallback onTrustDetails;
  final VoidCallback onBenefitDetails;

  final VoidCallback onMyJobs;
  final VoidCallback onInvitations;
  final VoidCallback onFavouriteWorkers;
  final VoidCallback onMyReviews;
  final VoidCallback onPaymentHistory;

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
            EmployerProfileHeader(profile: profile, onEditPressed: onEditProfile),

            const SizedBox(height: 18),

            EmployerProfileStats(profile: profile),

            const SizedBox(height: 14),

            EmployerTrustCard(profile: profile, onTap: onTrustDetails),

            if (profile.hasWorkerProfile) ...[
              const SizedBox(height: 14),
              EmployerBenefitCard(profile: profile, onTap: onBenefitDetails),
            ],

            const SizedBox(height: 22),

            EmployerProfileSection(
              title: 'Activity',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons.description_outlined,
                  title: 'My Jobs',
                  onTap: onMyJobs,
                  iconColor: AppColors.info,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.mail_outline_rounded,
                  title: 'Invitations',
                  onTap: onInvitations,
                  iconColor: AppColors.info,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.favorite_rounded,
                  title: 'Favourite Workers',
                  onTap: onFavouriteWorkers,
                  iconColor: AppColors.error,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.star_rounded,
                  title: 'My Reviews',
                  onTap: onMyReviews,
                  iconColor: AppColors.warning,
                ),
                EmployerProfileMenuItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment History',
                  onTap: onPaymentHistory,
                  iconColor: AppColors.info,
                ),
              ],
            ),

            const SizedBox(height: 18),

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

            if (profile.hasWorkerProfile) ...[
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

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
  }
}
