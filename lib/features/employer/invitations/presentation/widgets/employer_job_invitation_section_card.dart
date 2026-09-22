import 'package:flutter/widgets.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerJobInvitationSectionCard
    extends StatelessWidget {
  const EmployerJobInvitationSectionCard({super.key, 
    required this.child,
  });

  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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