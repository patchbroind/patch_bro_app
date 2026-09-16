import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

class EmployerWorkerDetailsSkills extends StatelessWidget {
  const EmployerWorkerDetailsSkills({
    super.key,
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: worker.skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            skill,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}