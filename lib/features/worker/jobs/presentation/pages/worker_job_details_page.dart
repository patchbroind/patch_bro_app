
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';

import 'package:patch_bro/features/worker/home/domain/entities/worker_home_job_entity.dart';

import 'package:patch_bro/features/worker/jobs/presentation/controllers/worker_job_progress_state.dart';
import 'package:patch_bro/features/worker/jobs/presentation/providers/worker_job_progress_providers.dart';

import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_description_card.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_images.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_location_card.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_schedule_card.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_voice_player.dart';

class WorkerJobDetailsPage extends ConsumerWidget {
  const WorkerJobDetailsPage({
    super.key,
    required this.job,
  });

  final WorkerHomeJobEntity job;

  // ----------------------------------------------------------
  // JOB STATUS
  // ----------------------------------------------------------

  String get _statusLabel {
    final status = job.status.trim().toLowerCase();

    switch (status) {
      case 'completed':
        return 'Completed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      case 'expired':
        return 'Expired';

      case 'in_progress':
      case 'in-progress':
        return 'In Progress';

      case 'accepted':
      case 'assigned':
        return 'Accepted';

      default:
        return 'Upcoming';
    }
  }

  Color get _statusColor {
    switch (job.status.trim().toLowerCase()) {
      case 'completed':
        return WorkerColors.success;

      case 'cancelled':
      case 'canceled':
      case 'expired':
        return WorkerColors.error;

      default:
        return WorkerColors.homePrimary;
    }
  }

  // ----------------------------------------------------------
  // CHECK WHETHER JOB IS ACTIVE
  // ----------------------------------------------------------

  bool get _isJobActive {
    final status = job.status.trim().toLowerCase();

    // These job statuses should never show progress actions.
    if (const {
      'completed',
      'cancelled',
      'canceled',
      'expired',
    }.contains(status)) {
      return false;
    }

    // A job whose scheduled date has passed is expired.
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final jobDate = DateTime(
      job.scheduledDate.year,
      job.scheduledDate.month,
      job.scheduledDate.day,
    );

    return !jobDate.isBefore(today);
  }

  // ----------------------------------------------------------
  // PROGRESS BUTTON LABEL
  // ----------------------------------------------------------

  String _progressButtonLabel(String status) {
    switch (status) {
      case 'not_started':
        return 'On the way';

      case 'on_the_way':
        return 'Reached';

      case 'reached':
        return 'Create Job Sheet';

      default:
        return 'On the way';
    }
  }

  // ----------------------------------------------------------
  // PROGRESS BUTTON ICON
  // ----------------------------------------------------------

  IconData _progressButtonIcon(String status) {
    switch (status) {
      case 'not_started':
        return Icons.navigation_rounded;

      case 'on_the_way':
        return Icons.location_on_rounded;

      case 'reached':
        return Icons.description_outlined;

      default:
        return Icons.navigation_rounded;
    }
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= 700 ? 28.0 : 16.0;

    // Each job gets its own progress controller.
    final progressProvider = workerJobProgressControllerProvider((
      job.id,
      job.workerProgressStatus,
    ));

    final progressState = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: WorkerColors.homeBackground,

      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: false,
        backgroundColor: WorkerColors.homeBackground,
        foregroundColor: WorkerColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job header
                  _buildHeader(context),

                  const SizedBox(height: 16),

                  // Job images
                  if (job.hasImages) ...[
                    WorkerJobImages(
                      imageUrls: job.effectiveImageUrls,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Job schedule
                  WorkerJobScheduleCard(job: job),

                  const SizedBox(height: 16),

                  // Job location and Google Maps
                  WorkerJobLocationCard(job: job),

                  const SizedBox(height: 16),

                  // Job description
                  if (job.hasDescription) ...[
                    WorkerJobDescriptionCard(
                      description: job.description,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Voice note
                  if (job.hasVoiceNote) ...[
                    WorkerJobVoicePlayer(
                      audioUrl: job.audioUrl!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Additional information
                  _buildInformation(context),

                  // Worker progress action
                  if (_isJobActive) ...[
                    const SizedBox(height: 24),

                    _buildProgressAction(
                      context,
                      progressState,
                      () async {
                        final success = await ref
                            .read(progressProvider.notifier)
                            .advance();

                        if (!context.mounted) return;

                        if (success) {
                          final message =
                              progressState.status == 'not_started'
                                  ? 'You are on the way!'
                                  : 'You have reached the job location!';

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor:
                                    WorkerColors.homePrimary,
                              ),
                            );
                        } else {
                          final errorMessage = ref
                              .read(progressProvider)
                              .errorMessage;

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage ??
                                      'Unable to update job progress.',
                                ),
                                backgroundColor:
                                    WorkerColors.error,
                              ),
                            );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // WORKER PROGRESS ACTION
  // ----------------------------------------------------------

  Widget _buildProgressAction(
    BuildContext context,
    WorkerJobProgressState progressState,
    VoidCallback onPressed,
  ) {
    final isReached = progressState.status == 'reached';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPrimaryButton(
          label: _progressButtonLabel(progressState.status),

          backgroundColor: WorkerColors.homePrimary,

          labelStyle: const TextStyle(
            color: WorkerColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),

          leadingIcon: Icon(
            _progressButtonIcon(progressState.status),
            color: WorkerColors.white,
            size: 21,
          ),

          isLoading: progressState.isLoading,

          // Job Sheet functionality will be added later.
          onPressed: isReached ? null : onPressed,
        ),

        if (isReached) ...[
          const SizedBox(height: 12),

          Text(
            'You have reached the job location. '
            'Job Sheet creation will be available soon.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WorkerColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ],
    );
  }

  // ----------------------------------------------------------
  // JOB HEADER
  // ----------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: WorkerColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: WorkerColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                'Job #${job.id.length > 8 ? job.id.substring(0, 8) : job.id}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WorkerColors.textSecondary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            job.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: WorkerColors.textPrimary,
                ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                icon: Icons.category_outlined,
                label: job.category,
              ),

              _CategoryChip(
                icon: Icons.handyman_outlined,
                label: job.title,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // JOB INFORMATION
  // ----------------------------------------------------------

  Widget _buildInformation(BuildContext context) {
    return WorkerJobDetailSection(
      title: 'Job Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _InformationRow(
            label: 'Category',
            value: job.category,
          ),

          _InformationRow(
            label: 'Skill',
            value: job.title,
          ),

          _InformationRow(
            label: 'Status',
            value: _statusLabel,
          ),

          if (job.createdAt != null)
            _InformationRow(
              label: 'Posted On',
              value: MaterialLocalizations.of(context)
                  .formatMediumDate(job.createdAt!),
            ),

          if (job.updatedAt != null)
            _InformationRow(
              label: 'Last Updated',
              value: MaterialLocalizations.of(context)
                  .formatMediumDate(job.updatedAt!),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORY CHIP
// ============================================================

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: WorkerColors.homePrimaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: WorkerColors.homePrimary,
          ),

          const SizedBox(width: 6),

          Text(
            label.isEmpty ? 'Not specified' : label,
            style: const TextStyle(
              color: WorkerColors.homePrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFORMATION ROW
// ============================================================

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WorkerColors.textSecondary,
                  ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WorkerColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
