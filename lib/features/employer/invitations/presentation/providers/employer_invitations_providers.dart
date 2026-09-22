import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasource/employer_invitations_remote_data_source.dart';
import '../../data/repository/employer_invitations_repository_impl.dart';
import '../../domain/repository/employer_invitations_repository.dart';
import '../controllers/employer_invitations_controller.dart';
import '../controllers/employer_invitations_state.dart';

final employerInvitationsRemoteDataSourceProvider =
    Provider<EmployerInvitationsRemoteDataSource>(
  (ref) {
    return EmployerInvitationsRemoteDataSource(
      ref.read(supabaseClientProvider),
    );
  },
);

final employerInvitationsRepositoryProvider =
    Provider<EmployerInvitationsRepository>(
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