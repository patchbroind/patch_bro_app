import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_image_picker.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';

class PostJobWizardImagesStep extends StatelessWidget {
  const PostJobWizardImagesStep({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onRemove,
  });

  final PostJobState state;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) => PostJobSection(
        title: 'Add job images',
        subtitle: 'Images are optional. You can add up to two.',
        child: PostJobImagePicker(
          images: state.images,
          onAdd: onAdd,
          onRemove: onRemove,
        ),
      );
}
