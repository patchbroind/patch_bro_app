import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_favourite_workers_remote_data_source.dart';
import '../../data/repository/employer_favourite_workers_repository_impl.dart';
import '../../domain/repository/employer_favourite_workers_repository.dart';
import '../controllers/employer_favourite_workers_controller.dart';
import '../controllers/employer_favourite_workers_state.dart';

final employerFavouriteWorkersRemoteDataSourceProvider =
    Provider<EmployerFavouriteWorkersRemoteDataSource>((ref) {
      return EmployerFavouriteWorkersRemoteDataSource(ref.read(supabaseClientProvider));
    });

final employerFavouriteWorkersRepositoryProvider = Provider<EmployerFavouriteWorkersRepository>((
  ref,
) {
  return EmployerFavouriteWorkersRepositoryImpl(
    ref.read(employerFavouriteWorkersRemoteDataSourceProvider),
  );
});

final employerFavouriteWorkersControllerProvider =
    NotifierProvider<EmployerFavouriteWorkersController, EmployerFavouriteWorkersState>(
      EmployerFavouriteWorkersController.new,
    );
