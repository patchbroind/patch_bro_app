import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_home_section.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_home_section_state.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_job_invitation_card.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerLatestInvitationSection extends StatelessWidget {
  const WorkerLatestInvitationSection({
    super.key,
    required this.invitation,
    required this.isLoading,
    required this.errorMessage,
    required this.respondingInvitationId,
    required this.onAccept,
    required this.onDecline,
    required this.respondingAction,
  });

  final JobInvitationEntity? invitation;
  final bool isLoading;
  final String? errorMessage;
  final String? respondingInvitationId;
  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;
  final InvitationResponseAction? respondingAction;

  @override
  Widget build(BuildContext context) {
    final cardPadding = const EdgeInsets.fromLTRB(16, 14, 16, 12);

    return WorkerHomeSection(
      title: 'Latest Invitation',
      // subtitle: 'You have a new job invitation',
      icon: Icons.bolt_rounded,
      iconBackgroundColor: WorkerColors.homePrimary.withValues(alpha: 0.12),
      iconColor: WorkerColors.homePrimary,
      padding: cardPadding,
      // trailing: Text(
      //   invitation == null ? '' : _relativeTime(invitation!.createdAt),
      //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
      //     color: WorkerColors.textSecondary,
      //     fontWeight: FontWeight.w600,
      //   ),
      // ),
      child: WorkerHomeSectionState(
        isLoading: isLoading,
        errorMessage: errorMessage,
        isEmpty: !isLoading && errorMessage == null && invitation == null,
        emptyMessage: 'No active invitations right now.',
        emptyIcon: Icons.event_busy_rounded,
        child: invitation == null
            ? const SizedBox.shrink()
            : WorkerJobInvitationCard(
                invitation: invitation!,
                respondingInvitationId: respondingInvitationId,
                respondingAction: respondingAction,
                onAccept: onAccept,
                onDecline: onDecline,
              ),
      ),
    );
  }

  // String _relativeTime(DateTime dateTime) {
  //   final delta = DateTime.now().difference(dateTime);
  //   if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
  //   if (delta.inHours < 24) return '${delta.inHours}h ago';
  //   return '${delta.inDays}d ago';
  // }
}
