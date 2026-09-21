import 'package:flutter/material.dart';
import 'package:patch_bro/core/widgets/app_divider.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_info_row.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_section_card.dart';

class JobDetailInformationCard
    extends StatelessWidget {
  const JobDetailInformationCard({super.key, 
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialLocalizations.of(
      context,
    );

    return JobDetailSectionCard(
      title: 'Job Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          JobDetailInfoRow(
            label: 'Job ID',
            value: job.id,
            selectable: true,
          ),
          const AppDivider(),
          JobDetailInfoRow(
            label: 'Status',
            value: job.statusLabel,
          ),
          const AppDivider(),
          JobDetailInfoRow(
            label: 'Category',
            value: job.category,
          ),
          const AppDivider(),
          JobDetailInfoRow(
            label: 'Skill',
            value: job.skill,
          ),
          const AppDivider(),
          JobDetailInfoRow(
            label: 'Created On',
            value: _formatDateTime(
              context,
              job.createdAt,
              localizations,
            ),
          ),
          const AppDivider(),
          JobDetailInfoRow(
            label: 'Last Updated',
            value: _formatDateTime(
              context,
              job.updatedAt,
              localizations,
            ),
          ),
          if (job.hasLocation) ...[
            const AppDivider(),
            JobDetailInfoRow(
              label: 'Coordinates',
              value:
                  '${job.latitude!.toStringAsFixed(6)}, '
                  '${job.longitude!.toStringAsFixed(6)}',
              selectable: true,
            ),
          ],
          const AppDivider(),
          JobDetailInfoRow(
            label: 'Voice Description',
            value:
                job.hasVoiceDescription
                    ? 'Available'
                    : 'Not added',
          ),
        ],
      ),
    );
  }

  String _formatDateTime(
    BuildContext context,
    DateTime value,
    MaterialLocalizations localizations,
  ) {
    final date =
        localizations.formatMediumDate(
      value,
    );

    final time =
        localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
    );

    return '$date • $time';
  }
}