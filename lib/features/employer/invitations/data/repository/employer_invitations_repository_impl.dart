import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../../domain/repository/employer_invitations_repository.dart';
import '../datasource/employer_invitations_remote_data_source.dart';

class EmployerInvitationsRepositoryImpl implements EmployerInvitationsRepository {
  EmployerInvitationsRepositoryImpl(this._remoteDataSource);

  final EmployerInvitationsRemoteDataSource _remoteDataSource;

  @override
  Future<JobInvitationEntity> inviteWorker({
    required String jobId,
    required String workerId,
  }) async {
    final invitation = await _remoteDataSource.inviteWorker(jobId: jobId, workerId: workerId);

    return invitation.toEntity();
  }

  @override
  Future<List<JobInvitationEntity>> getJobInvitations(String jobId) async {
    final models = await _remoteDataSource.getJobInvitations(jobId);

    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<List<JobInvitationEntity>> getWorkerInvitationStatuses(String workerId) async {
    final models = await _remoteDataSource.getWorkerInvitationStatuses(workerId);

    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Stream<void> watchJobInvitations(String jobId) {
    return _remoteDataSource.watchJobInvitations(jobId);
  }
}
