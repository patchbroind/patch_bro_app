import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_card_container.dart';

class JobDetailSectionCard extends StatelessWidget {
  const JobDetailSectionCard({super.key, 
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return JobDetailCardContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    AppColors.employerPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color:
                          AppColors.textPrimary,
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
