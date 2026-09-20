import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

import 'package:patch_bro/features/worker/profile/presentation/widgets/worker_profile_section_widget.dart';

class WorkerProfileProfession extends StatelessWidget {
  const WorkerProfileProfession({
    super.key,
    required this.profession,
    required this.professions,
    required this.onChanged,
  });

  final String profession;
  final List<String> professions;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return WorkerProfileSection(
      title: 'Profession',
      child: DropdownButtonFormField<String>(
        initialValue: profession,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.construction_outlined,
            color: AppColors.workerPrimary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: professions
            .map(
              (profession) =>
                  DropdownMenuItem<String>(
                value: profession,
                child: Text(profession),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }

          onChanged(value);
        },
      ),
    );
  }
}