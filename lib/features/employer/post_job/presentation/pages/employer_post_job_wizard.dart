import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/location/location_service.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/utils/date_time_utils.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/core/widgets/work_time_slot_grid.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';
import 'package:patch_bro/features/employer/home/presentation/providers/employer_home_provider.dart';
import 'package:patch_bro/features/employer/jobs/presentation/providers/employer_jobs_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/employer_job_post_selection_tile.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_image_picker.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_voice_recorder.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_header.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_location_option.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_selection_step.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';
import 'package:patch_bro/features/profile/presentation/pages/location_picker_page.dart';

/// Create-only job flow. The edit screen deliberately remains the original
/// single-page form in [EmployerPostJobPage].
class EmployerPostJobWizard extends ConsumerStatefulWidget {
  const EmployerPostJobWizard({super.key});

  @override
  ConsumerState<EmployerPostJobWizard> createState() =>
      _EmployerPostJobWizardState();
}

class _EmployerPostJobWizardState extends ConsumerState<EmployerPostJobWizard> {
  late final TextEditingController _skillController;
  late final TextEditingController _descriptionController;
  late final ValueNotifier<String?> _categoryValueNotifier;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    ref.read(employerHomeControllerProvider.notifier).loadCategories();
    final state = ref.read(postJobControllerProvider);
    _skillController = TextEditingController(text: state.skill);
    _descriptionController = TextEditingController(text: state.description);
    _categoryValueNotifier = ValueNotifier<String?>(
      state.category.isEmpty ? null : state.category,
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _skillController.dispose();
    _descriptionController.dispose();
    _categoryValueNotifier.dispose();
    super.dispose();
  }

  Future<bool> _handleSystemBack() async {
    final controller = ref.read(postJobControllerProvider.notifier);
    final state = ref.read(postJobControllerProvider);
    if (state.currentStep == 0) return true;
    controller.goToPreviousStep();
    return false;
  }

  Future<void> _selectDate() async {
    final controller = ref.read(postJobControllerProvider.notifier);
    final state = ref.read(postJobControllerProvider);
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    var initialDate = state.selectedDate ?? firstDate;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;

    final selected = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2, now.month, now.day),
      initialDate: initialDate,
    );
    if (selected != null) controller.setDate(selected);
  }

  Future<void> _chooseLocation() async {
    final state = ref.read(postJobControllerProvider);
    final savedLocation = ref.read(employerHomeProvider).value?.location;
    final selected = await Navigator.of(context).push<ProfileLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLocation: state.locationAddress == null
              ? savedLocation
              : ProfileLocation(
                  latitude: state.latitude!,
                  longitude: state.longitude!,
                  address: state.locationAddress!,
                ),
        ),
      ),
    );
    if (selected != null && mounted) {
      ref.read(postJobControllerProvider.notifier).setLocation(selected);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final result = await LocationService().getCurrentLocation();
      if (!mounted) return;
      ref
          .read(postJobControllerProvider.notifier)
          .setLocation(
            ProfileLocation(
              latitude: result.latitude,
              longitude: result.longitude,
              address: result.address,
            ),
          );
    } catch (error) {
      if (mounted) AppSnackbar.error(context, error.toString());
    }
  }

  Future<void> _startRecording() async {
    final controller = ref.read(postJobControllerProvider.notifier);
    await controller.startRecording();
    if (!mounted || !ref.read(postJobControllerProvider).isRecording) return;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final state = ref.read(postJobControllerProvider);
      if (!state.isRecording) {
        _recordingTimer?.cancel();
        return;
      }
      controller.updateRecordingDuration(
        state.recordingDuration + const Duration(seconds: 1),
      );
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    await ref.read(postJobControllerProvider.notifier).stopRecording();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final jobId = await ref
        .read(postJobControllerProvider.notifier)
        .submitJob();
    if (!mounted) return;
    if (jobId == null || jobId.isEmpty) {
      final error = ref.read(postJobControllerProvider).errorMessage;
      if (error != null) AppSnackbar.error(context, error);
      return;
    }

    // Fetch the server list before changing tabs; the existing jobs screen
    // observes the same provider and therefore never needs an optimistic copy.
    try {
      await ref.read(employerJobsControllerProvider.notifier).refreshJobs();
    } catch (_) {
      // Creation succeeded. The Jobs page retains its normal retry behaviour.
    }
    if (!mounted) return;
    ref.read(postJobControllerProvider.notifier).reset();
    context.goNamed(RouteNames.employerJobs);
    AppSnackbar.success(context, 'Job posted successfully.');
  }

  void _next() {
    final advanced = ref
        .read(postJobControllerProvider.notifier)
        .goToNextStep();
    if (!advanced && mounted) {
      final error = ref.read(postJobControllerProvider).errorMessage;
      if (error != null) AppSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobControllerProvider);
    ref.listen<String>(
      postJobControllerProvider.select((state) => state.category),
      (previous, next) {
        _categoryValueNotifier.value = next.isEmpty ? null : next;
      },
    );
    final categories = ref.watch(
      employerHomeControllerProvider.select(
        (homeState) => homeState.categories,
      ),
    );
    final isSubmitting = state.status == PostJobStatus.submitting;

    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Post a Job')),
        body: SafeArea(
          child: Column(
            children: [
              PostJobWizardHeader(step: state.currentStep),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: _buildStep(state, categories),
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    if (state.currentStep > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : ref
                                    .read(postJobControllerProvider.notifier)
                                    .goToPreviousStep,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: state.currentStep > 0 ? 2 : 1,
                      child: AppPrimaryButton(
                        label: state.currentStep == 5 ? 'Post Job' : 'Next',
                        isLoading: isSubmitting,
                        leadingIcon: Icon(
                          state.currentStep == 5
                              ? Icons.add_circle_outline
                              : Icons.arrow_forward,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : (state.currentStep == 5 ? _submit : _next),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(PostJobState state, List<CategoryEntity> categories) {
    return switch (state.currentStep) {
      0 => _categoryStep(state, categories),
      1 => _scheduleStep(state),
      2 => _locationStep(state),
      3 => _descriptionStep(state),
      4 => _imagesStep(state),
      _ => PostJobWorkerSelectionStep(),
    };
  }

  Widget _categoryStep(PostJobState state, List<CategoryEntity> categories) {
    final names = categories
        .where((item) => item.isActive)
        .map((item) => item.name)
        .toList();
    final selected = names.contains(state.category) ? state.category : null;
    if (_categoryValueNotifier.value != selected) {
      _categoryValueNotifier.value = selected;
    }
    return PostJobSection(
      title: 'Category and required skill',
      subtitle: 'Choose the work type and the primary skill you need.',
      child: Column(
        children: [
          DropdownButtonFormField2<String>(
            valueListenable: _categoryValueNotifier,
            isExpanded: true,
            decoration: const InputDecoration(
              hintText: 'Select job category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: names
                .map(
                  (name) =>
                      DropdownItem<String>(value: name, child: Text(name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(postJobControllerProvider.notifier).setCategory(value);
              }
            },
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _skillController,
            hintText: 'Required skill',
            icon: Icons.handyman_outlined,
            textInputAction: TextInputAction.next,
            onChanged: ref.read(postJobControllerProvider.notifier).setSkill,
          ),
          const SizedBox(height: 10),
          Text(
            'Skills are stored as one required-skill value by the current job API.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _scheduleStep(PostJobState state) => PostJobSection(
    title: 'Schedule',
    subtitle: 'Choose a date and one or more two-hour work slots.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionTile(
          icon: Icons.calendar_today_outlined,
          title: 'Date',
          value: DateTimeUtils.formatDate(state.selectedDate),
          onTap: _selectDate,
        ),
        const SizedBox(height: 16),
        WorkTimeSlotGrid(
          selectedSlotIds: state.selectedSlotIds.toSet(),
          onSlotToggled: ref
              .read(postJobControllerProvider.notifier)
              .toggleTimeSlot,
          color: AppColors.employerPrimary,
        ),
        const SizedBox(height: 12),
        Text(
          '${state.selectedSlotIds.length} time slot${state.selectedSlotIds.length == 1 ? '' : 's'} selected'
          '${state.selectedSlotIds.isNotEmpty ? ' · ${state.selectedSlotIds.length * 2} working hours' : ''}'
          ' (lunch break is 12–1 PM)',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  Widget _locationStep(PostJobState state) {
    final savedLocation = ref.watch(employerHomeProvider).value?.location;
    final hasSelectedLocation =
        state.locationAddress?.trim().isNotEmpty == true;
    final isSavedSelected =
        savedLocation != null &&
        state.latitude == savedLocation.latitude &&
        state.longitude == savedLocation.longitude;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostJobSection(
          title: 'Your saved location',
          subtitle: savedLocation == null
              ? 'No saved profile location is available.'
              : 'Use your profile location or select another place.',
          child: savedLocation == null
              ? const Text(
                  'Choose a different location or use your current location.',
                )
              : PostJobWizardLocationOption(
                  icon: Icons.home_outlined,
                  title: savedLocation.address,
                  subtitle: isSavedSelected
                      ? 'Selected for this job'
                      : 'Use this saved location',
                  selected: isSavedSelected,
                  onTap: () => ref
                      .read(postJobControllerProvider.notifier)
                      .setLocation(savedLocation),
                ),
        ),
        const SizedBox(height: 18),
        PostJobSection(
          title: 'Job location',
          subtitle: hasSelectedLocation
              ? 'Selected location is shown below.'
              : 'Select where the worker should arrive.',
          child: Column(
            children: [
              if (hasSelectedLocation) ...[
                PostJobWizardLocationOption(
                  icon: Icons.location_on_outlined,
                  title: state.locationAddress!,
                  subtitle: 'Currently selected',
                  selected: true,
                  onTap: _chooseLocation,
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _chooseLocation,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Choose a different location'),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use current location'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _descriptionStep(PostJobState state) => PostJobSection(
    title: 'Job description',
    subtitle: 'Add text, a voice description, or both.',
    child: Column(
      children: [
        AppTextField(
          controller: _descriptionController,
          hintText: 'Describe the job...',
          icon: Icons.description_outlined,
          maxLength: 1000,
          keyboardType: TextInputType.multiline,
          onChanged: ref
              .read(postJobControllerProvider.notifier)
              .setDescription,
        ),
        const SizedBox(height: 12),
        PostJobVoiceRecorder(
          isRecording: state.isRecording,
          duration: state.recordingDuration,
          hasRecording: state.voiceRecording != null,
          onStart: _startRecording,
          onStop: _stopRecording,
          onRemove: ref
              .read(postJobControllerProvider.notifier)
              .removeVoiceRecording,
        ),
      ],
    ),
  );

  Widget _imagesStep(PostJobState state) => PostJobSection(
    title: 'Add job images',
    subtitle: 'Images are optional. You can add up to two.',
    child: PostJobImagePicker(
      images: state.images,
      onAdd: ref.read(postJobControllerProvider.notifier).pickImages,
      onRemove: ref.read(postJobControllerProvider.notifier).removeImage,
    ),
  );
}
