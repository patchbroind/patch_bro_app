import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerInvitationsState {
  const WorkerInvitationsState({
    this.isLoading = false,
    this.invitations = const [],
    this.respondingInvitationId,
    this.errorMessage,
    this.respondingAction,
  });

  final bool isLoading;

  final List<JobInvitationEntity> invitations;

  final String? respondingInvitationId;

  final String? errorMessage;
  
  final InvitationResponseAction? respondingAction;

   bool get isRespondingToInvitation =>
      respondingInvitationId != null;

  WorkerInvitationsState copyWith({
    bool? isLoading,
    List<JobInvitationEntity>? invitations,
    String? respondingInvitationId,
    String? errorMessage,
    bool clearError = false,
    bool clearResponding = false,
    InvitationResponseAction? respondingAction,
  }) {
    return WorkerInvitationsState(
      isLoading: isLoading ?? this.isLoading,
      invitations: invitations ?? this.invitations,
      respondingInvitationId: clearResponding
          ? null
          : (respondingInvitationId ?? this.respondingInvitationId),
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      respondingAction: clearResponding
          ? null
          : (respondingAction ?? this.respondingAction),
    );
  }
}
