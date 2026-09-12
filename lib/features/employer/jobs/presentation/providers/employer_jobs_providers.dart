import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_jobs_remote_data_source.dart';
import '../../data/repository/employer_jobs_repository_impl.dart';
import '../../domain/repository/employer_jobs_repository.dart';
import '../controllers/employer_jobs_controller.dart';
import '../controllers/employer_jobs_state.dart';

final employerJobsRemoteDataSourceProvider = Provider<EmployerJobsRemoteDataSource>((ref) {
  return EmployerJobsRemoteDataSource(ref.read(supabaseClientProvider));
});

final employerJobsRepositoryProvider = Provider<EmployerJobsRepository>((ref) {
  return EmployerJobsRepositoryImpl(ref.read(employerJobsRemoteDataSourceProvider));
});

final employerJobsControllerProvider = NotifierProvider<EmployerJobsController, EmployerJobsState>(
  EmployerJobsController.new,
);
