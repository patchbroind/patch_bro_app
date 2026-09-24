import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../../data/datasource/employer_invitations_remote_data_source.dart';
import '../../data/repository/employer_invitations_repository_impl.dart';
import '../../domain/repository/employer_invitations_repository.dart';
import '../controllers/employer_invitations_controller.dart';
import '../controllers/employer_invitations_state.dart';

final employerInvitationsRemoteDataSourceProvider =
    Provider<
        EmployerInvitationsRemoteDataSource>(
  (ref) {
    return EmployerInvitationsRemoteDataSource(
      ref.read(
        supabaseClientProvider,
      ),
    );
  },
);

final employerInvitationsRepositoryProvider =
    Provider<
        EmployerInvitationsRepository>(
  (ref) {
    return EmployerInvitationsRepositoryImpl(
      ref.read(
        employerInvitationsRemoteDataSourceProvider,
      ),
    );
  },
);

final employerInvitationsControllerProvider =
    NotifierProvider.family<
        EmployerInvitationsController,
        EmployerInvitationsState,
        String>(
  EmployerInvitationsController.new,
);

/// Returns the current invitation status for
/// one worker across the employer's jobs.
///
/// This is used by the normal Workers tab when
/// the employer taps "Invite".
///
/// Important:
/// The key is still worker + job.
/// We never treat a worker as globally invited.
final employerWorkerInvitationStatusesProvider =
    FutureProvider.autoDispose.family<
        List<JobInvitationEntity>,
        String>(
  (ref, workerId) async {
    return ref
        .read(
          employerInvitationsRepositoryProvider,
        )
        .getWorkerInvitationStatuses(
          workerId,
        );
  },
);