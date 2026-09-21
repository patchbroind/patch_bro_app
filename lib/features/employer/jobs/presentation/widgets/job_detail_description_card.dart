import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_section_card.dart';

class JobDetailDescriptionCard extends StatelessWidget {
  const JobDetailDescriptionCard({super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return JobDetailSectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        description,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(
              color:
                  AppColors.textSecondary,
              height: 1.55,
            ),
      ),
    );
  }
}