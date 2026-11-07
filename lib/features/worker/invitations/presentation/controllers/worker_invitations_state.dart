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

  /// Pending invitations that have not expired.
  List<JobInvitationEntity> get activeInvitations {
    final result = invitations
        .where((item) => item.isActive)
        .toList();

    result.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return result;
  }

  /// Expired invitations, including pending invitations
  /// whose expiry timestamp has already passed.
  List<JobInvitationEntity> get expiredInvitations {
    final result = invitations.where((item) {
      return item.status == JobInvitationStatus.expired ||
          (item.isPending && !item.expiresAt.isAfter(DateTime.now()));
    }).toList();

    result.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return result;
  }

  int get activeCount => activeInvitations.length;

  int get expiredCount => expiredInvitations.length;

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
          : respondingInvitationId ?? this.respondingInvitationId,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      respondingAction: clearResponding
          ? null
          : respondingAction ?? this.respondingAction,
    );
  }
}