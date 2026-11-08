import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_filled_icon_button.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/invitations/presentation/providers/worker_invitations_providers.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/invitation_detail_card.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/invitation_detail_value.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/invitation_employer_card.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/invitation_media_gallery.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/invitation_voice_note.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../utils/invitation_time_slot_utils.dart';

class WorkerJobInvitationDetailsPage extends ConsumerWidget {
  const WorkerJobInvitationDetailsPage({super.key, required this.invitation, this.onViewEmployer});

  final JobInvitationEntity invitation;

  final VoidCallback? onViewEmployer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerInvitationsControllerProvider);

    // Prefer the latest entity from controller state. This matters when
    // realtime updates change the invitation status while this page is open.
    final currentInvitation =
        state.invitations.where((item) => item.id == invitation.id).firstOrNull ?? invitation;

    final isResponding = state.respondingInvitationId == currentInvitation.id;
    final canRespond = currentInvitation.canRespond && !isResponding;

    return Scaffold(
      backgroundColor: WorkerColors.homeBackground,
      appBar: AppBar(
        backgroundColor: WorkerColors.homeBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text('Invitation Details'),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _InvitationStatusBanner(
                    status: currentInvitation.statusLabel,
                    isPending: currentInvitation.isPending,
                  ),
                  const SizedBox(height: 14),

                  _CategorySkillSection(invitation: currentInvitation),
                  const SizedBox(height: 14),

                  _ScheduleSection(invitation: currentInvitation),
                  const SizedBox(height: 14),

                  _LocationSection(invitation: currentInvitation),
                  const SizedBox(height: 14),

                  _DescriptionSection(invitation: currentInvitation),

                  if (currentInvitation.hasVoiceNote) ...[
                    const SizedBox(height: 12),
                    InvitationVoiceNote(audioUrl: currentInvitation.audioUrl!),
                  ],

                  if (currentInvitation.hasImages) ...[
                    const SizedBox(height: 14),
                    InvitationMediaGallery(
                      imageUrls: currentInvitation.imageUrls,
                      onImageTap: (index) =>
                          _showImage(context, currentInvitation.imageUrls[index]),
                    ),
                  ],

                  const SizedBox(height: 14),

                  InvitationEmployerCard(
                    employerName: currentInvitation.employerName,
                    avatarUrl: currentInvitation.workerAvatarUrl,
                    onViewEmployer:
                        onViewEmployer ??
                        () => AppSnackbar.info(
                          context,
                          'Employer profile details are not connected yet.',
                        ),
                  ),
                ],
              ),
            ),

            _BottomActions(
              canRespond: canRespond,
              isResponding: isResponding,
              respondingAction: state.respondingAction,
              onDecline: () =>
                  _respond(context, ref, currentInvitation, InvitationResponseAction.decline),
              onAccept: () =>
                  _respond(context, ref, currentInvitation, InvitationResponseAction.accept),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    JobInvitationEntity invitation,
    InvitationResponseAction action,
  ) async {
    try {
      final controller = ref.read(workerInvitationsControllerProvider.notifier);

      if (action == InvitationResponseAction.accept) {
        await controller.accept(invitation.id);
      } else {
        await controller.reject(invitation.id);
      }

      if (!context.mounted) return;

      AppSnackbar.success(
        context,
        action == InvitationResponseAction.accept
            ? 'Invitation accepted successfully.'
            : 'Invitation declined.',
      );

      context.pop();
    } catch (error) {
      if (!context.mounted) return;

      AppSnackbar.error(context, error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showImage(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain, width: double.infinity),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationStatusBanner extends StatelessWidget {
  const _InvitationStatusBanner({required this.status, required this.isPending});

  final String status;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final background = isPending ? const Color(0xFFE8F5E9) : WorkerColors.imagePlaceholder;
    final foreground = isPending ? WorkerColors.homePrimary : WorkerColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(Icons.mail_outline_rounded, color: foreground, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Invitation',
                  style: TextStyle(fontWeight: FontWeight.w800, color: WorkerColors.textPrimary),
                ),
                SizedBox(height: 3),
                Text(
                  'Review the job details before responding.',
                  style: TextStyle(color: WorkerColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySkillSection extends StatelessWidget {
  const _CategorySkillSection({required this.invitation});

  final JobInvitationEntity invitation;

  @override
  Widget build(BuildContext context) {
    return InvitationDetailCard(
      icon: Icons.grid_view_rounded,
      title: 'Category & Skills',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (invitation.jobCategory.isNotEmpty)
            _InfoChip(icon: Icons.category_outlined, label: invitation.jobCategory),
          if (invitation.jobSkill.isNotEmpty)
            _InfoChip(icon: Icons.handyman_outlined, label: invitation.jobSkill),
          if (invitation.jobCategory.isEmpty && invitation.jobSkill.isEmpty)
            const Text(
              'No category or skill information available.',
              style: TextStyle(color: WorkerColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.invitation});

  final JobInvitationEntity invitation;

  @override
  Widget build(BuildContext context) {
    final date = invitation.scheduledDate == null
        ? 'Not specified'
        : DateFormat('EEE, d MMM yyyy').format(invitation.scheduledDate!);

    final slots = InvitationTimeSlotUtils.labels(invitation.scheduledSlotIds);

    return InvitationDetailCard(
      icon: Icons.calendar_month_outlined,
      title: 'Date & Time Slots',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InvitationDetailValue(label: 'Date', value: date),
          const SizedBox(height: 14),
          Text(
            'Selected time slots',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: WorkerColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (slots.isEmpty)
            Text(
              invitation.scheduledTime.isEmpty
                  ? 'No time slots specified'
                  : InvitationTimeSlotUtils.formatTime(invitation.scheduledTime),
              style: const TextStyle(color: WorkerColors.textPrimary, fontWeight: FontWeight.w700),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots
                  .map((slot) => _InfoChip(icon: Icons.access_time_rounded, label: slot))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.invitation});

  final JobInvitationEntity invitation;

  @override
  Widget build(BuildContext context) {
    final address = invitation.locationAddress.trim().isEmpty
        ? 'Location not available'
        : invitation.locationAddress;

    return InvitationDetailCard(
      icon: Icons.location_on_outlined,
      title: 'Location',
      child: Row(
        children: [
          Expanded(
            child: Text(
              address,
              style: const TextStyle(
                color: WorkerColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.location_on_rounded, color: WorkerColors.homePrimary),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.invitation});

  final JobInvitationEntity invitation;

  @override
  Widget build(BuildContext context) {
    return InvitationDetailCard(
      icon: Icons.description_outlined,
      title: 'Job Description',
      child: Text(
        invitation.description.trim().isEmpty
            ? 'No description provided by the employer.'
            : invitation.description,
        style: const TextStyle(color: WorkerColors.textPrimary, height: 1.55),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: WorkerColors.homeCategoryBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: WorkerColors.homePrimary),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: WorkerColors.homePrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.canRespond,
    required this.isResponding,
    required this.respondingAction,
    required this.onDecline,
    required this.onAccept,
  });

  final bool canRespond;
  final bool isResponding;
  final InvitationResponseAction? respondingAction;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        boxShadow: const [
          BoxShadow(color: WorkerColors.cardShadow, blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppPrimaryFilledIconButton(
                label: 'Decline',
                icon: Icons.close_rounded,
                onPressed: canRespond ? onDecline : null,
                isLoading: isResponding && respondingAction == InvitationResponseAction.decline,
                backgroundColor: WorkerColors.homeDeclineBackground,
                foregroundColor: WorkerColors.error,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPrimaryFilledIconButton(
                label: 'Accept',
                icon: Icons.check_rounded,
                onPressed: canRespond ? onAccept : null,
                isLoading: isResponding && respondingAction == InvitationResponseAction.accept,
                backgroundColor: WorkerColors.homePrimary,
                foregroundColor: WorkerColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
