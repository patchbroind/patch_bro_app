import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class WorkerInvitationsState {
  const WorkerInvitationsState({
    this.isLoading = false,
    this.invitations = const [],
    this.respondingInvitationId,
    this.errorMessage,
  });

  final bool isLoading;

  final List<JobInvitationEntity>
      invitations;

  final String?
      respondingInvitationId;

  final String? errorMessage;

  WorkerInvitationsState copyWith({
    bool? isLoading,
    List<JobInvitationEntity>?
        invitations,
    String? respondingInvitationId,
    String? errorMessage,
    bool clearError = false,
    bool clearResponding = false,
  }) {
    return WorkerInvitationsState(
      isLoading:
          isLoading ?? this.isLoading,
      invitations:
          invitations ?? this.invitations,
      respondingInvitationId:
          clearResponding
              ? null
              : respondingInvitationId ??
                  this.respondingInvitationId,
      errorMessage: clearError
          ? null
          : errorMessage ??
              this.errorMessage,
    );
  }
}