import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/worker/profile/presentation/widgets/worker_profile_section_widget.dart';


class WorkerProfileSkills extends StatelessWidget {
  const WorkerProfileSkills({
    super.key,
    required this.skills,
    required this.selectedSkills,
    required this.onSkillChanged,
  });

  final List<String> skills;
  final Set<String> selectedSkills;
  final void Function(
    String skill,
    bool selected,
  ) onSkillChanged;

  @override
  Widget build(BuildContext context) {
    return WorkerProfileSection(
      title: 'Skills',
      subtitle:
          'Select the services you can provide.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) {
          final selected =
              selectedSkills.contains(skill);

          return FilterChip(
            label: Text(skill, style: TextStyle(color:AppColors.black),),
            selected: selected,
            selectedColor:
                AppColors.workerLight,
            checkmarkColor:
                AppColors.workerPrimary,
            side: BorderSide(
              color: selected
                  ? AppColors.workerPrimary
                  : AppColors.border,
            ),
            onSelected: (value) {
              onSkillChanged(skill, value);
            },
          );
        }).toList(),
      ),
    );
  }
}