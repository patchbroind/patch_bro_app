import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';

class PostJobSelectedWorkersCount extends StatelessWidget {
  const PostJobSelectedWorkersCount({
    super.key,
    required this.jobState,
  });

  final PostJobState jobState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.employerLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${jobState.selectedWorkerIds.length}/5',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.employerDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}