import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import 'employer_profile_menu_tile.dart';

class EmployerProfileSection extends StatelessWidget {
  const EmployerProfileSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<EmployerProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 2,
              bottom: 8,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++)
                EmployerProfileMenuTile(
                  item: items[index],
                  showDivider: index < items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}