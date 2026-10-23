import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/scheduling/work_time_slot.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/work_time_slot_grid.dart';
import 'package:patch_bro/features/worker/profile/presentation/providers/worker_profile_providers.dart';

class WorkerAvailabilityPage extends ConsumerStatefulWidget {
  const WorkerAvailabilityPage({super.key});

  @override
  ConsumerState<WorkerAvailabilityPage> createState() =>
      _WorkerAvailabilityPageState();
}

class _WorkerAvailabilityPageState
    extends ConsumerState<WorkerAvailabilityPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, Map<String, String>> _schedule = const {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(workerProfileControllerProvider.notifier);
      if (ref.read(workerProfileControllerProvider).profile == null) {
        controller.loadProfile();
      }
    });
  }

  void _syncSchedule(Map<String, Map<String, String>> schedule) {
    if (_initialized ||
        ref.read(workerProfileControllerProvider).profile == null) {
      return;
    }
    _schedule = {
      for (final entry in schedule.entries) entry.key: Map.of(entry.value),
    };
    _initialized = true;
  }

  void _setAvailability(String slotId, WorkerSlotAvailability availability) {
    setState(() {
      final dateKey = formatScheduleDate(_selectedDate);
      final slots = Map<String, String>.of(_schedule[dateKey] ?? const {});
      if (availability == WorkerSlotAvailability.unavailable) {
        slots.remove(slotId);
      } else {
        slots[slotId] = availability.name;
      }
      if (slots.isEmpty) {
        _schedule.remove(dateKey);
      } else {
        _schedule[dateKey] = slots;
      }
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 2, today.month, today.day),
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
    );
    if (selected != null) setState(() => _selectedDate = selected);
  }

  Future<void> _save() async {
    final success = await ref
        .read(workerProfileControllerProvider.notifier)
        .saveAvailabilitySchedule(_schedule);
    if (!mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Availability schedule saved.');
    } else {
      final message = ref.read(workerProfileControllerProvider).errorMessage;
      AppSnackbar.error(
        context,
        message ?? 'Unable to save availability schedule.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerProfileControllerProvider);
    _syncSchedule(state.profile?.availabilitySchedule ?? const {});
    final dateKey = formatScheduleDate(_selectedDate);
    final current = _schedule[dateKey] ?? const <String, String>{};
    final availabilityBySlot = {
      for (final slot in WorkTimeSlot.values)
        slot.id: WorkerSlotAvailability.values.firstWhere(
          (value) => value.name == current[slot.id],
          orElse: () => WorkerSlotAvailability.unavailable,
        ),
    };
    final availableIds = availabilityBySlot.entries
        .where((entry) => entry.value == WorkerSlotAvailability.available)
        .map((entry) => entry.key)
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Schedule'),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: state.isLoading && state.profile == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.workerPrimary,
                ),
              )
            : state.isFailure && state.profile == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ??
                            'Unable to load your availability.',
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(workerProfileControllerProvider.notifier)
                            .loadProfile(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Set availability for a specific date',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose whether each two-hour slot is available, booked, or unavailable.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(_selectedDate),
                    ),
                  ),
                  const SizedBox(height: 18),
                  WorkTimeSlotGrid(
                    selectedSlotIds: availableIds,
                    onSlotToggled: (_) {},
                    availabilityBySlot: availabilityBySlot,
                    onAvailabilityChanged: (change) =>
                        _setAvailability(change.slotId, change.availability),
                    color: AppColors.workerPrimary,
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: 'Save Schedule',
                    isLoading: state.isSaving,
                    backgroundColor: AppColors.workerPrimary,
                    onPressed: state.isSaving ? null : _save,
                  ),
                ],
              ),
      ),
    );
  }
}
