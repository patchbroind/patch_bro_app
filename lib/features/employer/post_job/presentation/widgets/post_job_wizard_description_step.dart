import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_description_fields.dart';

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
    child: PostJobDescriptionFields(
      descriptionController: descriptionController,
      onDescriptionChanged: onDescriptionChanged,
      isRecording: state.isRecording,
      recordingDuration: state.recordingDuration,
      hasRecording: state.voiceRecording != null,
      onStartRecording: onStartRecording,
      onStopRecording: onStopRecording,
      onRemoveRecording: onRemoveRecording,
    ),
  );
}
