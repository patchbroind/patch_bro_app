import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class WorkerEliteProgressBanner extends StatelessWidget {
  const WorkerEliteProgressBanner({super.key, 
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
    final title = completedCount >= target ? 'Elite Worker Achieved' : 'Elite Worker Progress';
    final description = completedCount >= target
        ? 'You have reached the Elite Worker target.'
        : 'Complete $remaining more works to reach Elite Member and get exclusive benefits!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0F3D2E), Color(0xFF133E2F)],
        ),
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
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFE5C974), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                      ),
                    ),
                    Text(
                      '$completedCount / $target',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFFE5C974),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE5C974)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            height: 86,
            child: Image.asset('assets/images/worker/elite_progress_img.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}