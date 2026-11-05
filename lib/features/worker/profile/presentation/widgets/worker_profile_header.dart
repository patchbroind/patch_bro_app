import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerProfileHeader extends StatelessWidget {
  const WorkerProfileHeader({super.key, required this.isSetup});

  final bool isSetup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WorkerColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: WorkerColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handyman_outlined,
              color: WorkerColors.surface,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSetup
                      ? 'Build your professional profile'
                      : 'Your professional profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: WorkerColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tell employers what you do and when you are available.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WorkerColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
