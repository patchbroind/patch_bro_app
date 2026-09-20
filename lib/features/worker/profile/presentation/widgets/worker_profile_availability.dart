import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

import 'package:patch_bro/features/worker/profile/presentation/widgets/worker_profile_section_widget.dart';

class WorkerProfileAvailability extends StatelessWidget {
  const WorkerProfileAvailability({
    super.key,
    required this.days,
    required this.selectedDays,
    required this.availableToday,
    required this.availableTomorrow,
    required this.onDayChanged,
    required this.onAvailableTodayChanged,
    required this.onAvailableTomorrowChanged,
  });

  final List<String> days;
  final Set<String> selectedDays;

  final bool availableToday;
  final bool availableTomorrow;

  final void Function(
    String day,
    bool selected,
  ) onDayChanged;

  final ValueChanged<bool> onAvailableTodayChanged;

  final ValueChanged<bool> onAvailableTomorrowChanged;

  @override
  Widget build(BuildContext context) {
    return WorkerProfileSection(
      title: 'Availability',
      subtitle:
          'Choose the days you normally accept jobs.',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days.map((day) {
              final selected =
                  selectedDays.contains(day);

              return FilterChip(
                label: Text(day, style: TextStyle(color:AppColors.black)),
                selected: selected,
                selectedColor:
                    AppColors.workerLight,
                checkmarkColor:
                    AppColors.workerPrimary,
                side: BorderSide(
                  color: selected
                      ? AppColors.workerPrimary
                      : AppColors.border,
                ),
                onSelected: (value) {
                  onDayChanged(day, value);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available today'),
            value: availableToday,
            activeThumbColor:
                AppColors.workerPrimary,
            onChanged: onAvailableTodayChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available tomorrow'),
            value: availableTomorrow,
            activeThumbColor:
                AppColors.workerPrimary,
            onChanged: onAvailableTomorrowChanged,
          ),
        ],
      ),
    );
  }
}