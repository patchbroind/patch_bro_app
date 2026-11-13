import 'package:flutter/material.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitation_empty_state.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitation_list_item.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerInvitationList extends StatelessWidget {
  const WorkerInvitationList({
    super.key,
    required this.invitations,
    required this.isExpired,
    required this.isLoading,
    required this.respondingInvitationId,
    required this.respondingAction,
    required this.onAccept,
    required this.onDecline,
    required this.onViewDetails,
  });

  final List<JobInvitationEntity> invitations;
  final bool isExpired;
  final bool isLoading;

  final String? respondingInvitationId;
  final InvitationResponseAction? respondingAction;

  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;
  final ValueChanged<JobInvitationEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    if (isLoading && invitations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (invitations.isEmpty) {
      return WorkerInvitationEmptyState(
        isExpired: isExpired,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: invitations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final invitation = invitations[index];

        return WorkerInvitationListItem(
          invitation: invitation,
          isExpired: isExpired,
          respondingInvitationId: respondingInvitationId,
          respondingAction: respondingAction,
          onAccept: onAccept,
          onDecline: onDecline,
          onViewDetails: () => onViewDetails(invitation),
        );
      },
    );
  }
}