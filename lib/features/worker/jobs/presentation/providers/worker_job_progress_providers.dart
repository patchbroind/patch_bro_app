
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/network/network_providers.dart';

import '../../data/datasources/worker_job_progress_remote_data_source.dart';
import '../../data/repositories/worker_job_progress_repository_impl.dart';
import '../../domain/repositories/worker_job_progress_repository.dart';

import '../controllers/worker_job_progress_controller.dart';
import '../controllers/worker_job_progress_state.dart';

final workerJobProgressRemoteDataSourceProvider =
    Provider<WorkerJobProgressRemoteDataSource>((ref) {
  return WorkerJobProgressRemoteDataSource(
    ref.read(apiClientProvider),
  );
});

final workerJobProgressRepositoryProvider =
    Provider<WorkerJobProgressRepository>((ref) {
  return WorkerJobProgressRepositoryImpl(
    ref.read(workerJobProgressRemoteDataSourceProvider),
  );
});

final workerJobProgressControllerProvider =
    NotifierProvider.family<
        WorkerJobProgressController,
        WorkerJobProgressState,
        (String, String)
    >(
  WorkerJobProgressController.new,
);
