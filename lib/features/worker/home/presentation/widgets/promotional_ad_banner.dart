import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class PromotionalAdBanner extends StatelessWidget {
  const PromotionalAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: WorkerColors.homePromotionalBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROFESSIONAL TOOLS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: WorkerColors.homePrimary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Better Tools\nBrighter Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: WorkerColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quality tools for every skilled worker.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WorkerColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: WorkerColors.homePrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Shop Now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: WorkerColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.construction_rounded,
              size: 48,
              color: WorkerColors.homePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
