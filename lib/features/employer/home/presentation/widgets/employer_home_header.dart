import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

import '../../domain/entities/employer_home_entity.dart';

class EmployerHomeHeader extends StatelessWidget {
  const EmployerHomeHeader({
    super.key,
    required this.data,
    required this.onLocationTap,
    required this.onNotificationTap,
  });

  final EmployerHomeEntity data;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatarWidget(size: 44, name: data.name, imageUrl: data.avatarUrl),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.employerPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 2),

              GestureDetector(
                onTap: onLocationTap,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.location?.address ?? 'Add location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: data.location == null
                              ? AppColors.employerPrimary
                              : AppColors.textSecondary,
                          fontWeight: data.location == null ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.employerPrimary,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _locationText(ProfileLocation? location) {
    if (location == null) {
      return 'Add location';
    }

    final parts = <String>[];

    void add(String? value) {
      if (value == null || value.trim().isEmpty) {
        return;
      }

      final text = value.trim();

      if (!parts.contains(text)) {
        parts.add(text);
      }
    }

    // Preferred structured values.
    add(location.city);
    add(location.district);
    add(location.state);

    // If structured values are not available,
    // use the address stored in the database.
    if (parts.isEmpty) {
      final address = location.address.trim();

      if (address.isNotEmpty && address != 'Selected location') {
        return address;
      }

      return 'Add location';
    }

    return parts.join(', ');
  }
}
