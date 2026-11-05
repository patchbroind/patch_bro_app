import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerEliteProgressBanner extends StatelessWidget {
  const WorkerEliteProgressBanner({
    super.key,
    required this.completedCount,
    required this.target,
    required this.progress,
  });

  final int completedCount;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remaining = (target - completedCount).clamp(0, target);
    final title = completedCount >= target
        ? 'Elite Worker Achieved'
        : 'Elite Worker Progress';
    final description = completedCount >= target
        ? 'You have reached the Elite Worker target.'
        : 'Complete $remaining more works to reach Elite Member and get exclusive benefits!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: WorkerColors.eliteCardGradient,
              stops: [0.0, 0.42, 0.72, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF006B48).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: WorkerColors.eliteGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: WorkerColors.surface,
                            ),
                      ),
                    ),
                    Text(
                      '$completedCount / $target',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: WorkerColors.eliteGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: WorkerColors.surface.withValues(
                      alpha: 0.22,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      WorkerColors.eliteGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WorkerColors.surface.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            // height: 100,
            child: Image.asset(
              'assets/images/worker/elite_progress_img.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
