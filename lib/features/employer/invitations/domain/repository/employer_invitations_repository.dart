
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

abstract class EmployerInvitationsRepository {
  Future<JobInvitationEntity> inviteWorker({
    required String jobId,
    required String workerId,
  });

  Future<List<JobInvitationEntity>>
      getJobInvitations(
    String jobId,
  );

  Stream<void> watchJobInvitations(
    String jobId,
  );
}