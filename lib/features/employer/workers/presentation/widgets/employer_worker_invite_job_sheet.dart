import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/employer/invitations/presentation/providers/employer_invitations_providers.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/jobs/presentation/controllers/employer_jobs_state.dart';
import 'package:patch_bro/features/employer/jobs/presentation/providers/employer_jobs_providers.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_job_invite_title.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class EmployerWorkerInviteJobSheet extends ConsumerStatefulWidget {
  const EmployerWorkerInviteJobSheet({super.key, required this.workerId});

  final String workerId;

  @override
  ConsumerState<EmployerWorkerInviteJobSheet> createState() => _EmployerWorkerInviteJobSheetState();
}

class _EmployerWorkerInviteJobSheetState extends ConsumerState<EmployerWorkerInviteJobSheet> {
  late final ValueNotifier<String?> _invitingJobId;

  @override
  void initState() {
    super.initState();

    _invitingJobId = ValueNotifier<String?>(null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final jobsState = ref.read(employerJobsControllerProvider);

      if (!jobsState.hasJobs && !jobsState.isLoading) {
        ref.read(employerJobsControllerProvider.notifier).loadJobs();
      }
    });
  }

  @override
  void dispose() {
    _invitingJobId.dispose();
    super.dispose();
  }

  Future<void> _inviteForJob(EmployerJobEntity job) async {
    if (_invitingJobId.value != null) {
      return;
    }

    _invitingJobId.value = job.id;

    try {

      await ref
          .read(employerInvitationsControllerProvider(job.id).notifier)
          .inviteWorker(widget.workerId);

      ref.invalidate(employerWorkerInvitationStatusesProvider(widget.workerId));

      if (!mounted) {
        return;
      }

      AppSnackbar.success(
        context,
        'Worker invited successfully. '
        'The invitation is valid for 15 minutes.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString();

      AppSnackbar.error(context, message.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        _invitingJobId.value = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(employerJobsControllerProvider);

    final invitationStatus = ref.watch(employerWorkerInvitationStatusesProvider(widget.workerId));

    final activeJobs = jobsState.jobs
        .where((job) => job.status == EmployerJobStatus.active)
        .toList(growable: false);

    final invitations = invitationStatus.value ?? const [];

    final invitationByJobId = <String, JobInvitationEntity>{
      for (final invitation in invitations) invitation.jobId: invitation,
    };

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          spacing: 12,
          children: [

            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.employerLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_outlined, color: AppColors.employerPrimary),
                  ),

                  const Expanded(
                    child: Column(
                      spacing: 3,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Worker',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        Text(
                          'Select an active job',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: _invitingJobId,
                builder: (context, _, child) {
                  return _buildBody(
                    context,
                    jobsState,
                    activeJobs,
                    invitationByJobId,
                    invitationStatus,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    EmployerJobsState jobsState,
    List<EmployerJobEntity> activeJobs,
    Map<String, JobInvitationEntity> invitationByJobId,
    AsyncValue<List<JobInvitationEntity>> invitationStatus,
  ) {
    if (jobsState.isLoading && !jobsState.hasJobs) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (jobsState.isFailure && !jobsState.hasJobs) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 42, color: AppColors.textSecondary),

              const SizedBox(height: 4),

              const Text(
                'Unable to load jobs',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),

              Text(
                jobsState.errorMessage ?? 'Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () {
                  ref.read(employerJobsControllerProvider.notifier).loadJobs();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (activeJobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline, size: 48, color: AppColors.imagePlaceholderIcon),

              SizedBox(height: 8),

              Text(
                'No active jobs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              Text(
                'Create an active job before inviting this worker.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: activeJobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final job = activeJobs[index];

        final invitation = invitationByJobId[job.id];

        final isInvited = invitation?.status == JobInvitationStatus.pending;

        final isAccepted = invitation?.status == JobInvitationStatus.accepted;

        return EmployerWorkerJobInviteTile(
          job: job,
          isInvited: isInvited,
          isAccepted: isAccepted,
          isLoading: _invitingJobId.value == job.id,
          onInvite: isInvited || isAccepted ? null : () => _inviteForJob(job),
        );
      },
    );
  }
}
