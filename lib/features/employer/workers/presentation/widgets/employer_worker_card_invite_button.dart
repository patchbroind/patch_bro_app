import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerWorkerCardInviteButton extends StatelessWidget {
  const EmployerWorkerCardInviteButton({
    super.key,
    required this.isInviting,
    required this.isInvited,
    required this.onInvite,
  });

  final bool isInviting;
  final bool isInvited;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton.icon(
        onPressed: isInviting || isInvited ? null : onInvite,
        icon: isInviting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(isInvited ? Icons.check_circle_outline : Icons.send_outlined, size: 18),
        label: Text(isInvited ? 'Invited' : 'Invite'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.employerPrimary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: isInvited ? AppColors.success.withValues(alpha: 0.15) : null,
          disabledForegroundColor: isInvited ? AppColors.success : null,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
