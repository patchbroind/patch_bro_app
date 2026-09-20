import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/employer/profile/presentation/providers/employer_profile_providers.dart';
import 'package:patch_bro/features/employer/profile/presentation/widgets/employer_profile_settings_content.dart';


class EmployerSettingsAndSupportPage
    extends ConsumerStatefulWidget {
  const EmployerSettingsAndSupportPage({
    super.key,
  });

  @override
  ConsumerState<
      EmployerSettingsAndSupportPage>
  createState() =>
      _EmployerSettingsAndSupportPageState();
}

class _EmployerSettingsAndSupportPageState
    extends ConsumerState<
        EmployerSettingsAndSupportPage> {
  bool _isLoggingOut = false;

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    final confirmed =
        await AppDialog.confirm(
      context,
      title: 'Logout',
      message:
          'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
      icon: Icons.logout_rounded,
      barrierDismissible: false,
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
     await ref.read(signOutProvider)();
      

      if (!mounted) {
        return;
      }

      AppSnackbar.success(
        context,
        'Logged out successfully.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoggingOut = false;
      });

      AppSnackbar.error(
        context,
        'Unable to logout. Please try again.',
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final profile = ref
        .watch(
          employerProfileControllerProvider,
        )
        .profile;

    return Scaffold(
          backgroundColor:
              AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Settings And Support',
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: _isLoggingOut
                  ? null
                  : () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              EmployerProfileSettingsContent(
                profile: profile,
                onPersonalInformation:
                    () {
                  context.pushNamed(
                    RouteNames
                        .employerPersonalInformation,
                  );
                },
                onAddresses: () {
                  context.pushNamed(
                    RouteNames.employerAddresses,
                  );
                },
                onNotifications: () {
                  context.pushNamed(
                    RouteNames
                        .employerNotifications,
                  );
                },
                onSecurity: () {
                  AppSnackbar.info(
                    context,
                    'Security & Privacy will be available soon.',
                  );
                },
               
                onHelp: () {
                  AppSnackbar.info(
                    context,
                    'Help & Support will be available soon.',
                  );
                },
                onTerms: () {
                  AppSnackbar.info(
                    context,
                    'Terms & Conditions will be available soon.',
                  );
                },
                onPrivacy: () {
                  AppSnackbar.info(
                    context,
                    'Privacy Policy will be available soon.',
                  );
                },
                onLogout: _logout,
              ),
              if (_isLoggingOut)
          const _LogoutLoadingOverlay(),
            ],
          ),
        );
  }
}


class _LogoutLoadingOverlay
    extends StatelessWidget {
  const _LogoutLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black26,
          alignment: Alignment.center,
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  color: Colors.black12,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color:
                        AppColors
                            .employerPrimary,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Logging out...',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
