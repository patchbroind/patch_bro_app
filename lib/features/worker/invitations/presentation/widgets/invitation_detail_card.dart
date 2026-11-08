import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class InvitationDetailCard extends StatelessWidget {
  const InvitationDetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WorkerColors.border),
        boxShadow: const [
          BoxShadow(
            color: WorkerColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: WorkerColors.homePrimaryLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: WorkerColors.homePrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: WorkerColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}