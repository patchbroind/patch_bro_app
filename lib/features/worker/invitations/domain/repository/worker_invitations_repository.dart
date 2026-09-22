import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

abstract class WorkerInvitationsRepository {
  Future<List<JobInvitationEntity>>
      getInvitations();

  Future<void> acceptInvitation(
    String invitationId,
  );

  Future<void> rejectInvitation(
    String invitationId,
  );

  Stream<void>
      watchInvitations();
}