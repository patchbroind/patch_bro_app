import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/worker/invitations/presentation/controllers/worker_invitations_state.dart';

import '../../data/datasource/worker_invitations_remote_data_source.dart';
import '../../data/repository/worker_invitations_repository_impl.dart';
import '../../domain/repository/worker_invitations_repository.dart';
import '../controllers/worker_invitations_controller.dart';

final workerInvitationsRemoteDataSourceProvider =
    Provider<
        WorkerInvitationsRemoteDataSource>(
  (ref) {
    return WorkerInvitationsRemoteDataSource(
      ref.read(supabaseClientProvider),
    );
  },
);

final workerInvitationsRepositoryProvider =
    Provider<WorkerInvitationsRepository>(
  (ref) {
    return WorkerInvitationsRepositoryImpl(
      ref.read(
        workerInvitationsRemoteDataSourceProvider,
      ),
    );
  },
);

final workerInvitationsControllerProvider =
    NotifierProvider<
      WorkerInvitationsController,
      WorkerInvitationsState
    >(
      WorkerInvitationsController.new,
    );