import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AppEditButton extends StatelessWidget {
  const AppEditButton({super.key, 
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.edit_outlined,
            size: 19,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}