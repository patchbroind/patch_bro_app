
import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/home/domain/entities/worker_home_job_entity.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_description_card.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_images.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_location_card.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_schedule_card.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_voice_player.dart';

class WorkerJobDetailsPage extends StatelessWidget {
  const WorkerJobDetailsPage({
    super.key,
    required this.job,
  });

  final WorkerHomeJobEntity job;

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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= 700 ? 28.0 : 16.0;

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
                  _buildHeader(context),
                  const SizedBox(height: 16),

                  if (job.hasImages) ...[
                    WorkerJobImages(
                      imageUrls: job.effectiveImageUrls,
                    ),
                    const SizedBox(height: 16),
                  ],

                  WorkerJobScheduleCard(job: job),
                  const SizedBox(height: 16),

                  WorkerJobLocationCard(job: job),
                  const SizedBox(height: 16),

                  if (job.hasDescription) ...[
                    WorkerJobDescriptionCard(
                      description: job.description,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (job.hasVoiceNote) ...[
                    WorkerJobVoicePlayer(
                      audioUrl: job.audioUrl!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildInformation(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WorkerColors.border),
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