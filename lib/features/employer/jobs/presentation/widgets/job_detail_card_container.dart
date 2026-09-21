import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class JobDetailCardContainer
    extends StatelessWidget {
  const JobDetailCardContainer({super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

