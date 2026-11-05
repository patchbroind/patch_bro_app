import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerBottomNavBar extends StatelessWidget {
  const WorkerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _labels = [
    'Home',
    'Location',
    'Availability',
    'Performance',
    'Profile',
  ];
  static const _icons = [
    Icons.home_rounded,
    Icons.location_on_outlined,
    Icons.access_time_rounded,
    Icons.bar_chart_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: WorkerColors.surface,
          border: Border(
            top: BorderSide(color: WorkerColors.border.withValues(alpha: 0.8)),
          ),
          boxShadow: [
            BoxShadow(
              color: WorkerColors.navigationShadow,
              blurRadius: 18,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_labels.length, (index) {
            final selected = index == currentIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onDestinationSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _icons[index],
                        size: 24,
                        color: selected
                            ? WorkerColors.homePrimary
                            : WorkerColors.textSecondary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _labels[index],
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? WorkerColors.homePrimary
                                  : WorkerColors.textSecondary,
                            ) ??
                            const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: WorkerColors.textSecondary,
                            ),
                      ),
                      if (selected)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: WorkerColors.homePrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
