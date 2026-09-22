
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../../domain/repository/worker_invitations_repository.dart';
import '../datasource/worker_invitations_remote_data_source.dart';

class WorkerInvitationsRepositoryImpl
    implements WorkerInvitationsRepository {
  WorkerInvitationsRepositoryImpl(
    this._remoteDataSource,
  );

  final WorkerInvitationsRemoteDataSource
      _remoteDataSource;

  @override
  Future<List<JobInvitationEntity>>
      getInvitations() async {
    final models =
        await _remoteDataSource
            .getInvitations();

    return models
        .map(
          (model) =>
              model.toEntity(),
        )
        .toList(
          growable: false,
        );
  }

  @override
  Future<void> acceptInvitation(
    String invitationId,
  ) {
    return _remoteDataSource
        .acceptInvitation(
      invitationId,
    );
  }

  @override
  Future<void> rejectInvitation(
    String invitationId,
  ) {
    return _remoteDataSource
        .rejectInvitation(
      invitationId,
    );
  }

  @override
  Stream<void>
      watchInvitations() {
    return _remoteDataSource
        .watchInvitations();
  }
}