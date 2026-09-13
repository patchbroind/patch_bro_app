import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';
import 'package:patch_bro/features/profile/presentation/pages/location_picker_page.dart';

import '../controllers/post_job_state.dart';
import '../providers/post_job_providers.dart';
import '../widgets/post_job_image_picker.dart';
import '../widgets/post_job_location_field.dart';
import '../widgets/post_job_section.dart';
import '../widgets/post_job_voice_recorder.dart';

class EmployerPostJobPage extends ConsumerStatefulWidget {
  const EmployerPostJobPage({
    super.key,
  });

  @override
  ConsumerState<EmployerPostJobPage> createState() =>
      _EmployerPostJobPageState();
}

class _EmployerPostJobPageState
    extends ConsumerState<EmployerPostJobPage> {
  late final TextEditingController _categoryController;
  late final TextEditingController _skillController;
  late final TextEditingController _descriptionController;

  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();

    _categoryController = TextEditingController();
    _skillController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _categoryController.dispose();
    _skillController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final controller =
        ref.read(postJobControllerProvider.notifier);

    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(
        now.year + 2,
        now.month,
        now.day,
      ),
      initialDate: now,
    );

    if (selected != null) {
      controller.setDate(selected);
    }
  }

  Future<void> _selectTime() async {
    final controller =
        ref.read(postJobControllerProvider.notifier);

    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected == null) {
      return;
    }

    final now = DateTime.now();

    controller.setTime(
      DateTime(
        now.year,
        now.month,
        now.day,
        selected.hour,
        selected.minute,
      ),
    );
  }

  Future<void> _selectLocation() async {
  final location = await Navigator.of(context)
      .push<ProfileLocation>(
    MaterialPageRoute(
      builder: (_) => const LocationPickerPage(),
    ),
  );

  if (location != null) {
    ref
        .read(postJobControllerProvider.notifier)
        .setLocation(location);
  }
}

  Future<void> _startRecording() async {
    await ref
        .read(postJobControllerProvider.notifier)
        .startRecording();

    if (!mounted) return;

    final state = ref.read(postJobControllerProvider);

    if (state.isRecording) {
      _recordingTimer?.cancel();

      _recordingTimer = Timer.periodic(
  const Duration(seconds: 1),
  (_) {
    final currentState =
        ref.read(postJobControllerProvider);

    if (!currentState.isRecording) {
      _recordingTimer?.cancel();
      return;
    }

    ref
        .read(postJobControllerProvider.notifier)
        .updateRecordingDuration(
          currentState.recordingDuration +
              const Duration(seconds: 1),
        );
  },
);
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    await ref
        .read(postJobControllerProvider.notifier)
        .stopRecording();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(postJobControllerProvider.notifier)
        .submitJob();

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Job submitted successfully.',
          ),
        ),
      );
    } else {
      final state =
          ref.read(postJobControllerProvider);

      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return 'Select time';
    }

    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobControllerProvider);

    ref.listen<PostJobState>(
      postJobControllerProvider,
      (previous, next) {
        if (next.status == PostJobStatus.success &&
            previous?.status != PostJobStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Job submitted successfully.',
              ),
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post a Job'),
        centerTitle: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= 600
                    ? 32.0
                    : 16.0;

            final contentWidth =
                constraints.maxWidth >= 900
                    ? 760.0
                    : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: contentWidth,
                ),
                child: Form(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),

                        PostJobSection(
                          title: 'Job Details',
                          subtitle:
                              'Tell workers what kind of work you need.',
                          child: Column(
                            children: [
                              AppTextField(
                                controller:
                                    _categoryController,
                                hintText:
                                    'Enter job category',
                                icon: Icons.category_outlined,
                                textInputAction:
                                    TextInputAction.next,
                                onChanged: ref
                                    .read(
                                      postJobControllerProvider
                                          .notifier,
                                    )
                                    .setCategory,
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller:
                                    _skillController,
                                hintText:
                                    'Required skill',
                                icon: Icons.handyman_outlined,
                                textInputAction:
                                    TextInputAction.next,
                                onChanged: ref
                                    .read(
                                      postJobControllerProvider
                                          .notifier,
                                    )
                                    .setSkill,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        PostJobSection(
                          title: 'Schedule',
                          subtitle:
                              'Choose when the work needs to be done.',
                          child: Row(
                            children: [
                              Expanded(
                                child: _SelectionTile(
                                  icon:
                                      Icons.calendar_today_outlined,
                                  title: 'Date',
                                  value:
                                      _formatDate(
                                    state.selectedDate,
                                  ),
                                  onTap: _selectDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SelectionTile(
                                  icon:
                                      Icons.access_time_outlined,
                                  title: 'Time',
                                  value:
                                      _formatTime(
                                    state.selectedTime,
                                  ),
                                  onTap: _selectTime,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        PostJobSection(
                          title: 'Location',
                          subtitle:
                              'Where should the worker arrive?',
                          child: PostJobLocationField(
                            address:
                                state.locationAddress,
                            onTap:
                                _selectLocation,
                          ),
                        ),

                        const SizedBox(height: 24),

                        PostJobSection(
                          title: 'Description',
                          subtitle:
                              'Describe the work clearly for workers.',
                          child: Column(
                            children: [
                              AppTextField(
                                controller:
                                    _descriptionController,
                                hintText:
                                    'Describe the job...',
                                icon:
                                    Icons.description_outlined,
                                maxLength: 1000,
                                keyboardType:
                                    TextInputType.multiline,
                                onChanged: ref
                                    .read(
                                      postJobControllerProvider
                                          .notifier,
                                    )
                                    .setDescription,
                              ),
                              const SizedBox(height: 12),
                              PostJobVoiceRecorder(
                                isRecording:
                                    state.isRecording,
                                duration:
                                    state.recordingDuration,
                                hasRecording:
                                    state.voiceRecording !=
                                        null,
                                onStart:
                                    _startRecording,
                                onStop:
                                    _stopRecording,
                                onRemove: ref
                                    .read(
                                      postJobControllerProvider
                                          .notifier,
                                    )
                                    .removeVoiceRecording,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        PostJobSection(
                          title: 'Job Images',
                          subtitle:
                              'Add up to 2 images to help workers understand the job.',
                          child: PostJobImagePicker(
                            images: state.images,
                            onAdd: ref
                                .read(
                                  postJobControllerProvider
                                      .notifier,
                                )
                                .pickImages,
                            onRemove: ref
                                .read(
                                  postJobControllerProvider
                                      .notifier,
                                )
                                .removeImage,
                          ),
                        ),

                        const SizedBox(height: 32),

                        _buildSubmitButton(
                          context,
                          state,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Find the right worker for the job',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Provide the job details so verified workers can understand what you need.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    PostJobState state,
  ) {
    final isSubmitting =
        state.status == PostJobStatus.submitting;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
            isSubmitting ? null : _submit,
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Post Job',
                  ),
                ],
              ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        !value.startsWith('Select');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.employerLight,
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.employerPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}