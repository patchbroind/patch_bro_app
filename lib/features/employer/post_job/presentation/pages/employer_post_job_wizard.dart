import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/location/location_service.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';
import 'package:patch_bro/features/employer/home/presentation/providers/employer_home_provider.dart';
import 'package:patch_bro/features/employer/jobs/presentation/providers/employer_jobs_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_category_step.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_description_step.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_header.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_images_step.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_location_step.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_schedule_step.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_selection_step.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';
import 'package:patch_bro/features/profile/presentation/pages/location_picker_page.dart';

/// Create-only job flow. The edit screen deliberately remains the original
/// single-page form in [EmployerPostJobPage].
class EmployerPostJobWizard extends ConsumerStatefulWidget {
  const EmployerPostJobWizard({super.key});

  @override
  ConsumerState<EmployerPostJobWizard> createState() => _EmployerPostJobWizardState();
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
    _categoryValueNotifier = ValueNotifier<String?>(state.category.isEmpty ? null : state.category);
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
      controller.updateRecordingDuration(state.recordingDuration + const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    await ref.read(postJobControllerProvider.notifier).stopRecording();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final jobId = await ref.read(postJobControllerProvider.notifier).submitJob();
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
    final advanced = ref.read(postJobControllerProvider.notifier).goToNextStep();
    if (!advanced && mounted) {
      final error = ref.read(postJobControllerProvider).errorMessage;
      if (error != null) AppSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobControllerProvider);
    ref.listen<String>(postJobControllerProvider.select((state) => state.category), (
      previous,
      next,
    ) {
      _categoryValueNotifier.value = next.isEmpty ? null : next;
    });
    final categories = ref.watch(
      employerHomeControllerProvider.select((homeState) => homeState.categories),
    );
    final isSubmitting = state.status == PostJobStatus.submitting;

    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _handleSystemBack();
      },
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
                              : ref.read(postJobControllerProvider.notifier).goToPreviousStep,
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
                          state.currentStep == 5 ? Icons.add_circle_outline : Icons.arrow_forward,
                        ),
                        onPressed: isSubmitting ? null : (state.currentStep == 5 ? _submit : _next),
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
    final controller = ref.read(postJobControllerProvider.notifier);
    return switch (state.currentStep) {
      0 => PostJobWizardCategoryStep(
        categories: categories,
        selectedCategory: state.category,
        categoryValueNotifier: _categoryValueNotifier,
        skillController: _skillController,
        onCategoryChanged: controller.setCategory,
        onSkillChanged: controller.setSkill,
      ),
      1 => PostJobWizardScheduleStep(
        state: state,
        onSelectDate: _selectDate,
        onSlotToggled: controller.toggleTimeSlot,
      ),
      2 => _buildLocationStep(state),
      3 => PostJobWizardDescriptionStep(
        state: state,
        descriptionController: _descriptionController,
        onDescriptionChanged: controller.setDescription,
        onStartRecording: _startRecording,
        onStopRecording: _stopRecording,
        onRemoveRecording: controller.removeVoiceRecording,
      ),
      4 => PostJobWizardImagesStep(
        state: state,
        onAdd: controller.pickImages,
        onRemove: controller.removeImage,
      ),
      _ => PostJobWorkerSelectionStep(),
    };
  }

  Widget _buildLocationStep(PostJobState state) {
    final savedLocation = ref.watch(employerHomeProvider).value?.location;
    return PostJobWizardLocationStep(
      savedLocation: savedLocation,
      selectedAddress: state.locationAddress,
      latitude: state.latitude,
      longitude: state.longitude,
      onChooseLocation: _chooseLocation,
      onUseCurrentLocation: _useCurrentLocation,
      onSelectLocation: (location) =>
          ref.read(postJobControllerProvider.notifier).setLocation(location),
    );
  }
}
