import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/network/network_providers.dart';

import '../../data/datasource/worker_home_remote_data_source.dart';
import '../../data/repository/worker_home_repository_impl.dart';
import '../../domain/repository/worker_home_repository.dart';
import '../controllers/worker_home_controller.dart';
import '../controllers/worker_home_state.dart';

final workerHomeRemoteDataSourceProvider = Provider<WorkerHomeRemoteDataSource>((ref) {
  return WorkerHomeRemoteDataSource(ref.read(apiClientProvider));
});

final workerHomeRepositoryProvider = Provider<WorkerHomeRepository>((ref) {
  return WorkerHomeRepositoryImpl(ref.read(workerHomeRemoteDataSourceProvider));
});

final workerHomeControllerProvider =
    NotifierProvider<WorkerHomeController, WorkerHomeState>(WorkerHomeController.new);
