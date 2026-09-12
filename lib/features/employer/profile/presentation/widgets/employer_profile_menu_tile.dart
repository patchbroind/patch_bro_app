import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerProfileMenuItem {
  const EmployerProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppColors.employerPrimary,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final bool isDestructive;
}

class EmployerProfileMenuTile extends StatelessWidget {
  const EmployerProfileMenuTile({
    super.key,
    required this.item,
    required this.showDivider,
  });

  final EmployerProfileMenuItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final iconColor = item.isDestructive
        ? AppColors.error
        : item.iconColor;

    final textColor = item.isDestructive
        ? AppColors.error
        : AppColors.textPrimary;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 19,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 21,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (showDivider)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 62,
                color: AppColors.divider,
              ),
          ],
        ),
      ),
    );
  }
}