import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

class EmployerWorkerDetailsStats extends StatelessWidget {
  const EmployerWorkerDetailsStats({super.key, required this.worker});

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${worker.experienceYears}+',
            label: 'Years Experience',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '${worker.jobsCompleted}',
            label: 'Jobs Completed',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '${worker.responseRate}%',
            label: 'Response Rate',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
