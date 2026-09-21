import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AppDivider
    extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Divider(
        height: 1,
        color: AppColors.divider,
      ),
    );
  }
}