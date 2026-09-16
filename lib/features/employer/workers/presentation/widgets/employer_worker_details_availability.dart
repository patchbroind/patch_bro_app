import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

class EmployerWorkerDetailsAvailability extends StatelessWidget {
  const EmployerWorkerDetailsAvailability({
    super.key,
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  static const _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days.map((day) {
        final available = worker.availabilityDays.contains(day);

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: day == _days.last ? 0 : 5,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: available
                  ? AppColors.employerLight
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 3),
                Icon(
                  available
                      ? Icons.check_rounded
                      : Icons.remove_rounded,
                  size: 15,
                  color: available
                      ? AppColors.employerPrimary
                      : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}