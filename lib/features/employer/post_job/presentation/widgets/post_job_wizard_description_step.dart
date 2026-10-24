import 'package:flutter/material.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_voice_recorder.dart';

class PostJobWizardDescriptionStep extends StatelessWidget {
  const PostJobWizardDescriptionStep({
    super.key,
    required this.state,
    required this.descriptionController,
    required this.onDescriptionChanged,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onRemoveRecording,
  });

  final PostJobState state;
  final TextEditingController descriptionController;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onRemoveRecording;

  @override
  Widget build(BuildContext context) => PostJobSection(
        title: 'Job description',
        subtitle: 'Add text, a voice description, or both.',
        child: Column(
          children: [
            AppTextField(
              controller: descriptionController,
              hintText: 'Describe the job...',
              icon: Icons.description_outlined,
              maxLength: 1000,
              keyboardType: TextInputType.multiline,
              onChanged: onDescriptionChanged,
            ),
            const SizedBox(height: 12),
            PostJobVoiceRecorder(
              isRecording: state.isRecording,
              duration: state.recordingDuration,
              hasRecording: state.voiceRecording != null,
              onStart: onStartRecording,
              onStop: onStopRecording,
              onRemove: onRemoveRecording,
            ),
          ],
        ),
      );
}
