import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';
import 'package:patch_bro/features/employer/profile/presentation/widgets/employer_personal_info_row.dart';

import '../../domain/entities/employer_profile_entity.dart';
import '../controllers/employer_profile_state.dart';
import '../providers/employer_profile_providers.dart';

class EmployerPersonalInformationPage extends ConsumerStatefulWidget {
  const EmployerPersonalInformationPage({super.key});

  @override
  ConsumerState<EmployerPersonalInformationPage> createState() =>
      _EmployerPersonalInformationPageState();
}

class _EmployerPersonalInformationPageState extends ConsumerState<EmployerPersonalInformationPage> {
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

  Future<void> _refresh() async {
    try {
      await ref.read(employerProfileControllerProvider.notifier).refreshProfile();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to refresh profile. Please try again.');
    }
  }

  void _retry() {
    ref.read(employerProfileControllerProvider.notifier).loadProfile();
  }

  void _showPhotoUnavailable() {
    AppSnackbar.info(context, 'Profile photo upload is not available yet.');
  }

  void _showEditUnavailable() {
    AppSnackbar.info(context, 'Profile editing is not available yet.');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information'),centerTitle: true,leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerProfileState state) {
    if (state.isLoading && !state.hasProfile) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasProfile) {
      return AppErrorView(
        title: 'Unable to load Personal Information',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return AppErrorView(
        title: 'Unable to load Personal Information',
        message: 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _PersonalInformationContent(
        profile: profile,
        onPhotoTap: _showPhotoUnavailable,
        onEditTap: _showEditUnavailable,
      ),
    );
  }
}

class _PersonalInformationContent extends StatelessWidget {
  const _PersonalInformationContent({
    required this.profile,
    required this.onPhotoTap,
    required this.onEditTap,
  });

  final EmployerProfileEntity profile;
  final VoidCallback onPhotoTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 20.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 32),
          children: [
            Center(
              child: _AvatarWithPhotoAction(profile: profile, onPhotoTap: onPhotoTap),
            ),
            const SizedBox(height: 30),
            _InformationCard(
              children: [
                EmployerPersonalInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Full Name',
                  value: profile.fullName,
                ),
                const Divider(height: 28),
                EmployerPersonalInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: profile.phone,
                  verified: profile.phoneVerified,
                ),
                const Divider(height: 28),
                EmployerPersonalInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                  verified: profile.emailVerified,
                ),
                const Divider(height: 28),
                EmployerPersonalInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: profile.locationAddress,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              onPressed: onEditTap,
              backgroundColor: AppColors.info.withValues(alpha: 0.06),
              label:'Edit',
            ),
          ],
        );
      },
    );
  }
}

class _AvatarWithPhotoAction extends StatelessWidget {
  const _AvatarWithPhotoAction({required this.profile, required this.onPhotoTap});

  final EmployerProfileEntity profile;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: ProfileAvatarWidget(
              size: 104,
              name: profile.fullName,
              imageUrl: profile.avatarUrl,
            ),
          ),
          Positioned(
            right: -2,
            bottom: 0,
            child: Material(
              color: AppColors.employerPrimary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPhotoTap,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 19),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

