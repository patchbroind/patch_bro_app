import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_action_buttons.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_description_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_header.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_image_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_information_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_schedule_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_voice_description_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_details_location_card.dart';

import '../../domain/entities/employer_job_entity.dart';

class EmployerJobDetailsPage extends StatelessWidget {
  const EmployerJobDetailsPage({
    super.key,
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= 700
            ? 28.0
            : 16.0;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                spacing: 16,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  JobDetailHeader(job: job),
                  JobDetailScheduleCard(job: job),
                  JobDetailsLocationCard(job: job),
                  if (job.hasDescription) ...[
                    JobDetailDescriptionCard(
                      description:
                          job.description,
                    ),

                  ],
                  if (job.hasVoiceDescription) ...[
                    JobDetailVoiceDescriptionCard(
                      audioUrl:
                          job.audioUrl!,
                    ),

                  ],
                  if (job.hasImage) ...[
                    JobDetailImagesCard(
                      imageUrl:
                          job.imageUrl!,
                    ),

                  ],
                  JobDetailInformationCard(
                    job: job,
                  ),
                  const SizedBox(height: 8),
                  JobDetailActionButtons(job: job),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
