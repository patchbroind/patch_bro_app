import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EditJobSubHeader extends StatelessWidget {
  const EditJobSubHeader({
    super.key,
    required this.isEditMode,
  });

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      isEditMode
          ? 'Update the job details, images or voice description as needed.'
          : 'Provide the job details so verified workers can understand what you need.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
    );
  }
}
