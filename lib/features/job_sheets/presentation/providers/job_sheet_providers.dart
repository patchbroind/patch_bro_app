
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/job_sheet_remote_data_source.dart';
import '../../data/repositories/job_sheet_repository_impl.dart';
import '../../domain/entities/job_sheet_entity.dart';
import '../../domain/repositories/job_sheet_repository.dart';

final jobSheetRemoteDataSourceProvider =
    Provider<JobSheetRemoteDataSource>((ref) {
  return JobSheetRemoteDataSourceImpl(
    ref.read(apiClientProvider),
  );
});

final jobSheetRepositoryProvider =
    Provider<JobSheetRepository>((ref) {
  return JobSheetRepositoryImpl(
    ref.read(jobSheetRemoteDataSourceProvider),
  );
});

/// Fetches a Job Sheet for either the worker or employer app.
/// Returns null when no Job Sheet has been submitted.
final jobSheetProvider =
    FutureProvider.family<JobSheetEntity?, String>((ref, jobId) {
  return ref
      .watch(jobSheetRepositoryProvider)
      .getJobSheet(jobId);
});