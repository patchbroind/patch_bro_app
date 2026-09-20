import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/profile/domain/entities/employer_profile_entity.dart';
import 'package:patch_bro/features/employer/profile/presentation/widgets/employer_profile_menu_tile.dart';
import 'package:patch_bro/features/employer/profile/presentation/widgets/employer_profile_section.dart';

class EmployerProfileSettingsContent
    extends StatelessWidget {
  const EmployerProfileSettingsContent({super.key, 
    this.profile,
    required this.onPersonalInformation,
    required this.onAddresses,
    required this.onNotifications,
    required this.onSecurity,
    required this.onHelp,
    required this.onTerms,
    required this.onPrivacy,
    required this.onLogout,
  });

  final EmployerProfileEntity? profile;

  final VoidCallback
      onPersonalInformation;

  final VoidCallback onAddresses;

  final VoidCallback onNotifications;

  final VoidCallback onSecurity;


  final VoidCallback onHelp;

  final VoidCallback onTerms;

  final VoidCallback onPrivacy;

  final VoidCallback onLogout;

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder:
          (
        context,
        constraints,
      ) {
        final horizontalPadding =
            constraints.maxWidth >= 600
                ? 24.0
                : 16.0;

        return ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            32,
          ),
          children: [
            // ==================================================
            // PERSONAL
            // ==================================================

            EmployerProfileSection(
              title: 'Personal',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons
                      .person_outline_rounded,
                  title:
                      'Personal Information',
                  onTap:
                      onPersonalInformation,
                ),
                EmployerProfileMenuItem(
                  icon: Icons
                      .location_on_outlined,
                  title: 'Addresses',
                  onTap:
                      onAddresses,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==================================================
            // PREFERENCES
            // ==================================================

            EmployerProfileSection(
              title: 'Preferences',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons
                      .notifications_none_rounded,
                  title: 'Notifications',
                  onTap:
                      onNotifications,
                ),
                EmployerProfileMenuItem(
                  icon: Icons
                      .lock_outline_rounded,
                  title:
                      'Security & Privacy',
                  onTap: onSecurity,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==================================================
            // SUPPORT
            // ==================================================

            EmployerProfileSection(
              title: 'Support',
              items: [
                EmployerProfileMenuItem(
                  icon: Icons
                      .help_outline_rounded,
                  title: 'Help & Support',
                  onTap: onHelp,
                ),
                EmployerProfileMenuItem(
                  icon: Icons
                      .description_outlined,
                  title:
                      'Terms & Conditions',
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

            // ==================================================
            // LOGOUT
            // ==================================================

            EmployerProfileSection(
              title: '',
              items: [
                EmployerProfileMenuItem(
                  icon:
                      Icons.logout_rounded,
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