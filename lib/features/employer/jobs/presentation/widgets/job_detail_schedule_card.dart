import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_section_card.dart';

class JobDetailScheduleCard extends StatelessWidget {
  const JobDetailScheduleCard({super.key, 
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialLocalizations.of(
      context,
    );

    final date =
        localizations.formatMediumDate(
      job.date,
    );

    final time =
        localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(
        job.time,
      ),
    );

    return JobDetailSectionCard(
      title: 'Schedule',
      icon: Icons.calendar_month_outlined,
      child: Row(
        children: [
          Expanded(
            child: _InfoTile(
              icon:
                  Icons.calendar_today_outlined,
              label: 'Date',
              value: date,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _InfoTile(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: time,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            AppColors.imagePlaceholder,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                AppColors.employerPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
