import 'package:flutter/material.dart';

import 'package:patch_bro/core/validators/validators.dart';

import 'package:patch_bro/features/worker/profile/presentation/widgets/worker_profile_section_widget.dart';

class WorkerProfileAbout extends StatelessWidget {
  const WorkerProfileAbout({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return WorkerProfileSection(
      title: 'About you',
      subtitle:
          'Briefly describe your experience and services.',
      child: TextFormField(
        controller: controller,
        minLines: 4,
        maxLines: 6,
        maxLength: 500,
        validator: Validators.required,
        decoration: InputDecoration(
          hintText:
              'Tell employers about your work experience...',
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}