import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AppPrimaryOutlinedButton extends StatelessWidget {
  const AppPrimaryOutlinedButton({super.key, required this.label, this.icon, this.onPressed});

  final String label;
  final Widget? icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label:  Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.employerPrimary,
        side: const BorderSide(color: AppColors.employerPrimary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
