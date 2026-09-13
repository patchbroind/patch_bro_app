import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';


class PostJobVoiceRecorder extends StatelessWidget {
  final bool isRecording;
  final Duration duration;
  final bool hasRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRemove;

  const PostJobVoiceRecorder({
    super.key,
    required this.isRecording,
    required this.duration,
    required this.hasRecording,
    required this.onStart,
    required this.onStop,
    required this.onRemove,
  });

  String _formatDuration(Duration value) {
    final minutes =
        value.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        value.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.employerLight.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.employerPrimary.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.employerPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isRecording ? onStop : onStart,
              icon: Icon(
                isRecording
                    ? Icons.stop
                    : Icons.mic_none,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isRecording
                      ? 'Recording...'
                      : hasRecording
                          ? 'Voice description added'
                          : 'Add voice description',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  isRecording
                      ? _formatDuration(duration)
                      : hasRecording
                          ? 'Tap remove to record again'
                          : 'Describe the job using your voice',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (hasRecording && !isRecording)
            IconButton(
              onPressed: onRemove,
              tooltip: 'Remove recording',
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}