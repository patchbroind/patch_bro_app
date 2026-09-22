import 'package:flutter/foundation.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';


enum EmployerInvitationsStatus {
  initial,
  loading,
  success,
  failure,
}

@immutable
class EmployerInvitationsState {
  const EmployerInvitationsState({
    this.status =
        EmployerInvitationsStatus.initial,
    this.invitations = const [],
    this.invitingWorkerId,
    this.errorMessage,
  });

  final EmployerInvitationsStatus status;

  final List<JobInvitationEntity>
      invitations;

  final String? invitingWorkerId;

  final String? errorMessage;

  bool get isLoading =>
      status ==
      EmployerInvitationsStatus.loading;

  bool get hasInvitations =>
      invitations.isNotEmpty;

  int get activeCount =>
      invitations
          .where(
            (item) => item.isActive,
          )
          .length;

  int get remainingSlots {
    final remaining = 5 - activeCount;
    return remaining < 0 ? 0 : remaining;
  }

  Set<String> get activeWorkerIds =>
      invitations
          .where(
            (item) => item.isActive,
          )
          .map(
            (item) => item.workerId,
          )
          .toSet();

  JobInvitationEntity?
      get acceptedInvitation {
    for (final invitation
        in invitations) {
      if (invitation.status ==
          JobInvitationStatus.accepted) {
        return invitation;
      }
    }

    return null;
  }

  EmployerInvitationsState copyWith({
    EmployerInvitationsStatus? status,
    List<JobInvitationEntity>? invitations,
    String? invitingWorkerId,
    String? errorMessage,
    bool clearError = false,
    bool clearInvitingWorker = false,
  }) {
    return EmployerInvitationsState(
      status: status ?? this.status,
      invitations:
          invitations ?? this.invitations,
      invitingWorkerId:
          clearInvitingWorker
              ? null
              : invitingWorkerId ??
                  this.invitingWorkerId,
      errorMessage: clearError
          ? null
          : errorMessage ??
              this.errorMessage,
    );
  }
}