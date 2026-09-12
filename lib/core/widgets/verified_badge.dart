import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}