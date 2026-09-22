import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class WorkerJobInvitationDialogInfoRow
    extends StatelessWidget {
  const WorkerJobInvitationDialogInfoRow({super.key, 
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color:
                AppColors.textSecondary,
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty
                  ? 'Not specified'
                  : value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}