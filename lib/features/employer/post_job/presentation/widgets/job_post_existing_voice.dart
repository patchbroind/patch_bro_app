import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class JobPostExistingVoice extends StatelessWidget {
  const JobPostExistingVoice({
    super.key,
    required this.onPressed,
  });
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.employerLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.employerPrimary.withValues(alpha: 0.18)),
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
            child: const Icon(Icons.volume_up_outlined, color: Colors.white, size: 22),
          ),
    
          const SizedBox(width: 12),
    
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Existing voice description',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
    
                const SizedBox(height: 3),
    
                Text(
                  'Record a new one below to replace it.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
    
          IconButton(
            onPressed: onPressed?.call,
            tooltip: 'Remove existing voice',
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}