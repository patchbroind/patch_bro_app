import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';

class EmployerWorkerDetailsInviteBar extends StatelessWidget {
  const EmployerWorkerDetailsInviteBar({
    super.key,
    required this.onInvite,
  });

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          14,
        ),
        color: AppColors.white,
        child: AppPrimaryButton(
          label: 'Invite for Job',
          backgroundColor: AppColors.employerPrimary,
          onPressed: onInvite,
        ),
      ),
    );
  }
}