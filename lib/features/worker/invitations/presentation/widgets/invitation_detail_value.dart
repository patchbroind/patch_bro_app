import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class InvitationDetailValue extends StatelessWidget {
  const InvitationDetailValue({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WorkerColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WorkerColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}