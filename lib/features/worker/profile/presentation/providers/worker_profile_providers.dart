import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/worker/profile/data/datasource/worker_profile_remote_data_source.dart';
import 'package:patch_bro/features/worker/profile/data/repository/worker_profile_repository_impl.dart';
import 'package:patch_bro/features/worker/profile/domain/repository/worker_profile_repository.dart';

import '../controllers/worker_profile_controller.dart';
import '../controllers/worker_profile_state.dart';

final workerProfileRemoteDataSourceProvider =
    Provider<WorkerProfileRemoteDataSource>((ref) {
  return WorkerProfileRemoteDataSource(
    ref.read(supabaseClientProvider),
  );
});

final workerProfileRepositoryProvider =
    Provider<WorkerProfileRepository>((ref) {
  return WorkerProfileRepositoryImpl(
    ref.read(
      workerProfileRemoteDataSourceProvider,
    ),
  );
});

final workerProfileControllerProvider =
    NotifierProvider<
        WorkerProfileController,
        WorkerProfileState>(
  WorkerProfileController.new,
);