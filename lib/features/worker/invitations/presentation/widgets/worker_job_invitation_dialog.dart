import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_job_invitation_dialog_action_buttons.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_job_invitation_dialog_info_row.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../providers/worker_invitations_providers.dart';

class WorkerJobInvitationDialog extends ConsumerWidget {
  const WorkerJobInvitationDialog({super.key, required this.invitation});

  final JobInvitationEntity invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerInvitationsControllerProvider);

    final isResponding = state.respondingInvitationId == invitation.id;

    final canRespond = invitation.isActive && !isResponding;

    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: AppColors.workerLight, shape: BoxShape.circle),
            child: const Icon(Icons.work_outline, color: AppColors.workerPrimary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'New Job Invitation',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invitation.jobSkill,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(invitation.jobCategory, style: const TextStyle(color: AppColors.textSecondary)),

            const SizedBox(height: 18),

            WorkerJobInvitationDialogInfoRow(
              icon: Icons.person_outline,
              label: 'Employer',
              value: invitation.employerName,
            ),

            WorkerJobInvitationDialogInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: _formatDate(invitation.scheduledDate),
            ),

            WorkerJobInvitationDialogInfoRow(
              icon: Icons.access_time_outlined,
              label: 'Time',
              value: invitation.scheduledTime,
            ),

            WorkerJobInvitationDialogInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: invitation.locationAddress,
            ),

            if (invitation.description.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                invitation.description,
                style: const TextStyle(height: 1.45, color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 16),

            if (invitation.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'This invitation expires in ${_remainingText(invitation.expiresAt)}',
                  style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w600),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'This invitation has expired.',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      actions: [
        if (canRespond)
          WorkerJobInvitationDialogActionButtons(
            ref: ref,
            invitationID: invitation.id,
            isResponding: isResponding,
          ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not specified';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _remainingText(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      return '00:00';
    }

    final minutes = remaining.inMinutes.toString().padLeft(2, '0');

    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}
