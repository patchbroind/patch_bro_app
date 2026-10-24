import 'package:flutter/material.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/job_post_existing_voice.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_voice_recorder.dart';

class PostJobDescriptionFields extends StatelessWidget {
  const PostJobDescriptionFields({
    super.key,
    required this.descriptionController,
    required this.onDescriptionChanged,
    required this.isRecording,
    required this.recordingDuration,
    required this.hasRecording,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onRemoveRecording,
    this.hasExistingVoice = false,
    this.onRemoveExistingVoice,
  }) : assert(!hasExistingVoice || onRemoveExistingVoice != null);

  final TextEditingController descriptionController;
  final ValueChanged<String> onDescriptionChanged;
  final bool isRecording;
  final Duration recordingDuration;
  final bool hasRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onRemoveRecording;
  final bool hasExistingVoice;
  final VoidCallback? onRemoveExistingVoice;

  @override
  Widget build(BuildContext context) {
    final showExistingVoice = hasExistingVoice && !hasRecording;
    return Column(
      children: [
        AppTextField(
          controller: descriptionController,
          hintText: 'Describe the job...',
          icon: Icons.description_outlined,
          maxLength: 1000,
          keyboardType: TextInputType.multiline,
          onChanged: onDescriptionChanged,
        ),
        if (showExistingVoice) ...[
          const SizedBox(height: 12),
          JobPostExistingVoice(onPressed: onRemoveExistingVoice!),
        ],
        const SizedBox(height: 12),
        PostJobVoiceRecorder(
          isRecording: isRecording,
          duration: recordingDuration,
          hasRecording: hasRecording,
          onStart: onStartRecording,
          onStop: onStopRecording,
          onRemove: onRemoveRecording,
        ),
      ],
    );
  }
}
