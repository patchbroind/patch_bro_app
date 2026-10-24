import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/utils/date_time_utils.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/core/widgets/work_time_slot_grid.dart';
import 'package:patch_bro/features/employer/home/presentation/providers/employer_home_provider.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/pages/employer_post_job_wizard.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/employer_job_post_selection_tile.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/job_post_existing_voice.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';
import 'package:patch_bro/features/profile/presentation/pages/location_picker_page.dart';

import '../providers/post_job_providers.dart';
import '../widgets/edit_job_category_dropdown.dart';
import '../widgets/edit_job_sub_header.dart';
import '../widgets/post_job_image_picker.dart';
import '../widgets/post_job_invite_workers_dialog.dart';
import '../widgets/post_job_location_field.dart';
import '../widgets/post_job_voice_recorder.dart';

class EmployerEditJobPage extends ConsumerStatefulWidget {
  const EmployerEditJobPage({super.key, this.job});

  final EmployerJobEntity? job;

  @override
  ConsumerState<EmployerEditJobPage> createState() => _EmployerEditJobPageState();
}

class _EmployerEditJobPageState extends ConsumerState<EmployerEditJobPage> {
  late final TextEditingController _skillController;
  late final TextEditingController _descriptionController;
  late final ValueNotifier<String?> _categoryValueNotifier;

  Timer? _recordingTimer;

  bool get _isEditMode => widget.job != null;

  @override
  void initState() {
    super.initState();

    _skillController = TextEditingController();

    _descriptionController = TextEditingController();
    _categoryValueNotifier = ValueNotifier<String?>(null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _initializePage();
    });
  }

  void _initializePage() {
    final controller = ref.read(postJobControllerProvider.notifier);

    final job = widget.job;

    if (job == null) {
      // Create-mode session ownership belongs to the wizard entry points.
      // This prevents this persistent shell branch from erasing a category
      // selected on the Employer Home screen.
      return;
    }

    controller.initializeForEdit(job);

    _skillController.text = job.skill;

    _descriptionController.text = job.description;
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();

    _skillController.dispose();
    _descriptionController.dispose();
    _categoryValueNotifier.dispose();

    super.dispose();
  }
  // RESE====================

  void _resetForm() {
    _skillController.clear();
    _descriptionController.clear();

    _recordingTimer?.cancel();
    _recordingTimer = null;

    ref.read(postJobControllerProvider.notifier).reset();
  }
  // DAT====================

  Future<void> _selectDate() async {
    final controller = ref.read(postJobControllerProvider.notifier);

    final state = ref.read(postJobControllerProvider);

    final now = DateTime.now();

    final currentDate = state.selectedDate;

    final firstDate = DateTime(now.year, now.month, now.day);

    DateTime initialDate = currentDate ?? firstDate;

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final selected = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2, now.month, now.day),
      initialDate: initialDate,
    );

    if (selected != null) {
      controller.setDate(selected);
    }
  }

  // TIM====================

  // LOCATIO====================

  Future<void> _selectLocation() async {
    final location = await Navigator.of(
      context,
    ).push<ProfileLocation>(MaterialPageRoute(builder: (_) => const LocationPickerPage()));

    if (location != null) {
      ref.read(postJobControllerProvider.notifier).setLocation(location);
    }
  }

  // VOICE RECORDIN====================

  Future<void> _startRecording() async {
    final controller = ref.read(postJobControllerProvider.notifier);

    await controller.startRecording();

    if (!mounted) {
      return;
    }

    final state = ref.read(postJobControllerProvider);

    if (!state.isRecording) {
      return;
    }

    _recordingTimer?.cancel();

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      final currentState = ref.read(postJobControllerProvider);

      if (!currentState.isRecording) {
        _recordingTimer?.cancel();
        _recordingTimer = null;
        return;
      }

      ref
          .read(postJobControllerProvider.notifier)
          .updateRecordingDuration(currentState.recordingDuration + const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    await ref.read(postJobControllerProvider.notifier).stopRecording();
  }

  // SUBMI====================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final controller = ref.read(postJobControllerProvider.notifier);

    final jobId = await controller.submitJob();

    if (!mounted) {
      return;
    }

    if (jobId == null || jobId.isEmpty) {
      final state = ref.read(postJobControllerProvider);

      if (state.errorMessage != null) {
        AppSnackbar.error(context, state.errorMessage!);
      }

      return;
    }

    final state = ref.read(postJobControllerProvider);

    // EDIT MODE

    if (state.isEditMode) {
      if (!mounted) {
        return;
      }

      // Tell the previous page that the job was successfully updated.
      context.pop(true);

      return;
    }

    // CREATE MODE

    final category = state.category.trim();

    final skill = state.skill.trim();

    await _showInviteWorkersDialog(jobId: jobId, category: category, skill: skill);

    if (!mounted) {
      return;
    }

    _resetForm();
  }

  // INVITE WORKERS DIALO====================

  Future<void> _showInviteWorkersDialog({
    required String jobId,
    required String category,
    required String skill,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PostJobInviteWorkersDialog(
          category: category,
          skill: skill,
          onNotNow: () {
            Navigator.of(dialogContext).pop();
          },
          onInvite: () {
            Navigator.of(dialogContext).pop();

            _openWorkers(jobId: jobId, category: category, skill: skill);
          },
        );
      },
    );
  }

  void _openWorkers({required String jobId, required String category, required String skill}) {
    final queryParameters = <String, String>{'jobId': jobId};

    if (category.trim().isNotEmpty) {
      queryParameters['category'] = category.trim();
    }

    context.pushNamed(RouteNames.employerInviteWorkers, queryParameters: queryParameters);
  }

  @override
  Widget build(BuildContext context) {
    // The edit route retains the established full form and update flow. Only
    // newly created jobs use the five-step wizard.
    if (!_isEditMode) {
      final sessionId = ref.watch(
        postJobControllerProvider.select((state) => state.createSessionId),
      );
      return EmployerPostJobWizard(key: ValueKey(sessionId));
    }

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

    final title = _isEditMode ? 'Edit Job' : 'Post a Job';

    final buttonLabel = _isEditMode ? 'Save Changes' : 'Post Job';

    final buttonIcon = _isEditMode ? Icons.save_outlined : Icons.add_circle_outline;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;

            final contentWidth = constraints.maxWidth >= 900 ? 760.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditJobSubHeader(isEditMode: _isEditMode),

                      const SizedBox(height: 24),

                      // JOB DETAILS
                      PostJobSection(
                        title: 'Job Details',
                        subtitle: 'Tell workers what kind of work you need.',
                        child: Column(
                          children: [
                            EditJobCategoryDropdown(
                              categories: categories,
                              selectedCategory: state.category,
                              valueNotifier: _categoryValueNotifier,
                              onChanged: ref.read(postJobControllerProvider.notifier).setCategory,
                            ),

                            const SizedBox(height: 14),

                            AppTextField(
                              controller: _skillController,
                              hintText: 'Required skill',
                              icon: Icons.handyman_outlined,
                              textInputAction: TextInputAction.next,
                              onChanged: ref.read(postJobControllerProvider.notifier).setSkill,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SCHEDULE
                      PostJobSection(
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
                      ),

                      const SizedBox(height: 24),

                      // LOCATION
                      PostJobSection(
                        title: 'Location',
                        subtitle: 'Where should the worker arrive?',
                        child: PostJobLocationField(
                          address: state.locationAddress,
                          onTap: _selectLocation,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // DESCRIPTION + VOICE
                      PostJobSection(
                        title: 'Description',
                        subtitle: 'Describe the work clearly for workers.',
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

                            if (_isEditMode &&
                                state.hasExistingAudio &&
                                state.voiceRecording == null)
                              JobPostExistingVoice(
                                onPressed: () => ref
                                    .read(postJobControllerProvider.notifier)
                                    .removeExistingVoice(),
                              ),

                            if (_isEditMode &&
                                state.hasExistingAudio &&
                                state.voiceRecording == null)
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
                      ),

                      const SizedBox(height: 24),

                      PostJobSection(
                        title: 'Job Images',
                        subtitle: 'Add up to 2 images to help workers understand the job.',
                        child: PostJobImagePicker(
                          existingImages: state.existingImages.map((image) => image.url).toList(),
                          images: state.images,
                          onAdd: ref.read(postJobControllerProvider.notifier).pickImages,
                          onRemove: ref.read(postJobControllerProvider.notifier).removeImage,
                          onRemoveExisting: ref
                              .read(postJobControllerProvider.notifier)
                              .removeExistingImage,
                        ),
                      ),

                      const SizedBox(height: 32),

                      AppPrimaryButton(
                        label: buttonLabel,
                        isLoading: isSubmitting,
                        leadingIcon: Icon(buttonIcon),
                        onPressed: isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
