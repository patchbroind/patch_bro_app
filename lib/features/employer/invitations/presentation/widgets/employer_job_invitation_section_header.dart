import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerJobInvitationSectionHeader
    extends StatelessWidget {
  const EmployerJobInvitationSectionHeader({super.key, 
    required this.activeCount,
  });

  final int activeCount;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.people_alt_outlined,
          color:
              AppColors.employerPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Worker Invitations',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
          ),
        ),
        Text(
          '$activeCount / 5 active',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w600,
              ),
        ),
      ],
    );
  }
}