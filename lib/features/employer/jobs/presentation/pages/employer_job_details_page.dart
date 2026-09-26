import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/invitations/presentation/widgets/employer_job_invitations_sections.dart';
import 'package:patch_bro/features/employer/jobs/presentation/providers/employer_jobs_providers.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_action_buttons.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_description_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_header.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_image_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_information_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_schedule_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_voice_description_card.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_details_location_card.dart';

import '../../domain/entities/employer_job_entity.dart';

class EmployerJobDetailsPage extends ConsumerStatefulWidget {
  const EmployerJobDetailsPage({super.key, required this.job});

  final EmployerJobEntity job;

  @override
  ConsumerState<EmployerJobDetailsPage> createState() => _EmployerJobDetailsPageState();
}

class _EmployerJobDetailsPageState extends ConsumerState<EmployerJobDetailsPage> {
  late EmployerJobEntity _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  Future<void> _refreshJob() async {
    try {
      await ref.read(employerJobsControllerProvider.notifier).refreshJobs();

      if (!mounted) {
        return;
      }

      final jobsState = ref.read(employerJobsControllerProvider);

      EmployerJobEntity? updatedJob;

      for (final job in jobsState.jobs) {
        if (job.id == _job.id) {
          updatedJob = job;
          break;
        }
      }

      if (updatedJob != null) {
        setState(() {
          _job = updatedJob!;
        });
      }
    } catch (_) {
      // The edit itself was already successful.
      // Keep the currently displayed job if refreshing fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 700 ? 28.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Job Details'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobDetailHeader(job: _job),

                  JobDetailScheduleCard(job: _job),

                  JobDetailsLocationCard(job: _job),

                  if (_job.hasDescription) JobDetailDescriptionCard(description: _job.description),

                  if (_job.hasVoiceDescription)
                    JobDetailVoiceDescriptionCard(audioUrl: _job.audioUrl!),

                  if (_job.hasImage) JobDetailImagesCard(imageUrl: _job.imageUrl!),

                  JobDetailInformationCard(job: _job),

                  JobInvitationsSection(jobId: _job.id),

                  const SizedBox(height: 8),

                  JobDetailActionButtons(job: _job, onJobEdited: _refreshJob),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
