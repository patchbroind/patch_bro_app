import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_edit_button.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';

import '../../domain/entities/employer_profile_entity.dart';

class EmployerProfileHeader extends StatelessWidget {
  const EmployerProfileHeader({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  final EmployerProfileEntity profile;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ProfileAvatarWidget(
          size: 75,
          name: profile.fullName,
          imageUrl: profile.avatarUrl,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                profile.roleLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (profile.isTrusted)
                const _TrustedBadge(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AppEditButton(
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}



class _TrustedBadge extends StatelessWidget {
  const _TrustedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.employerLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 15,
            color: AppColors.employerPrimary,
          ),
          SizedBox(width: 5),
          Text(
            'Trusted Employer',
            style: TextStyle(
              color: AppColors.employerPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

