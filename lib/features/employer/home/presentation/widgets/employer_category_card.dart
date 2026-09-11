import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerCategoryCard extends StatelessWidget {
  const EmployerCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.employerPrimary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.employerPrimary, size: 27),
            ),

            const SizedBox(height: 7),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
