import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/employer/workers/data/datasource/employer_workers_remote_data_source.dart';
import 'package:patch_bro/features/employer/workers/data/repository/employer_workers_repository_impl.dart';
import 'package:patch_bro/features/employer/workers/domain/repository/employer_workers_repository.dart';

import '../controllers/employer_workers_controller.dart';
import '../controllers/employer_workers_state.dart';

final employerWorkersRemoteDataSourceProvider =
    Provider<EmployerWorkersRemoteDataSource>((ref) {
      return EmployerWorkersRemoteDataSource(ref.read(supabaseClientProvider));
    });

final employerWorkersRepositoryProvider = Provider<EmployerWorkersRepository>((
  ref,
) {
  return EmployerWorkersRepositoryImpl(
    ref.read(employerWorkersRemoteDataSourceProvider),
  );
});

final employerWorkersControllerProvider =
    NotifierProvider<EmployerWorkersController, EmployerWorkersState>(
      EmployerWorkersController.new,
    );
