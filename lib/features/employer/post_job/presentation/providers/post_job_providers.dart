import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/network/network_providers.dart';
import 'package:patch_bro/features/employer/post_job/data/datasource/post_job_remote_data_source.dart';
import 'package:patch_bro/features/employer/post_job/data/repositories/post_job_repository_impl.dart';
import 'package:patch_bro/features/employer/post_job/domain/repositories/post_job_repository.dart';

import '../controllers/post_job_controller.dart';
import '../controllers/post_job_state.dart';

final postJobRemoteDataSourceProvider =
    Provider<PostJobRemoteDataSource>((ref) {
  return PostJobRemoteDataSource(
    ref.read(apiClientProvider),
  );
});

final postJobRepositoryProvider =
    Provider<PostJobRepository>((ref) {
  return PostJobRepositoryImpl(
    ref.read(postJobRemoteDataSourceProvider),
  );
});

final postJobControllerProvider =
    NotifierProvider<PostJobController, PostJobState>(
  PostJobController.new,
);