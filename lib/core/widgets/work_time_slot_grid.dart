import 'package:flutter/material.dart';
import 'package:patch_bro/core/scheduling/work_time_slot.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class WorkTimeSlotGrid extends StatelessWidget {
  const WorkTimeSlotGrid({
    super.key,
    required this.selectedSlotIds,
    required this.onSlotToggled,
    this.availabilityBySlot,
    this.onAvailabilityChanged,
    this.color = AppColors.employerPrimary,
  });

  final Set<String> selectedSlotIds;
  final ValueChanged<String> onSlotToggled;
  final Map<String, WorkerSlotAvailability>? availabilityBySlot;
  final ValueChanged<({String slotId, WorkerSlotAvailability availability})>?
  onAvailabilityChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 360 ? 1 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: WorkTimeSlot.values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: onAvailabilityChanged == null ? 76 : 156,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final slot = WorkTimeSlot.values[index];
            final selected = selectedSlotIds.contains(slot.id);
            final availability =
                availabilityBySlot?[slot.id] ??
                WorkerSlotAvailability.unavailable;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onAvailabilityChanged == null
                  ? () => onSlotToggled(slot.id)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.09)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? color : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            slot.shortLabel,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (onAvailabilityChanged == null)
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selected ? color : AppColors.textSecondary,
                            size: 20,
                          )
                        else
                          Icon(
                            availability == WorkerSlotAvailability.available
                                ? Icons.check_circle
                                : availability == WorkerSlotAvailability.booked
                                ? Icons.event_busy
                                : Icons.circle_outlined,
                            color:
                                availability == WorkerSlotAvailability.available
                                ? AppColors.workerPrimary
                                : availability == WorkerSlotAvailability.booked
                                ? Colors.orange.shade700
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slot.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (onAvailabilityChanged != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: WorkerSlotAvailability.values
                            .map((value) {
                              final label = switch (value) {
                                WorkerSlotAvailability.unavailable => 'Off',
                                WorkerSlotAvailability.available => 'Available',
                                WorkerSlotAvailability.booked => 'Booked',
                              };
                              return ChoiceChip(
                                label: Text(label),
                                visualDensity: VisualDensity.compact,
                                selected: availability == value,
                                onSelected: (_) => onAvailabilityChanged!((
                                  slotId: slot.id,
                                  availability: value,
                                )),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
