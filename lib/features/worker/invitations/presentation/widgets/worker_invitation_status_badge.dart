import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerInvitationStatusBadge extends StatelessWidget {
  const WorkerInvitationStatusBadge({
    super.key,
    required this.label,
    this.isExpired = false,
  });

  final String label;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final color = isExpired
        ? WorkerColors.error
        : const Color(0xFF996000);

    final background = isExpired
        ? WorkerColors.error.withValues(alpha: 0.09)
        : const Color(0xFFFFF0CB);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}