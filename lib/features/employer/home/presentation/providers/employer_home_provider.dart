import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/employer/home/data/repository/employer_home_repository_impl.dart';
import 'package:patch_bro/features/employer/home/domain/repository/employer_home_repository.dart';
import 'package:patch_bro/features/employer/home/presentation/controllers/employer_home_controller.dart';
import 'package:patch_bro/features/employer/home/presentation/controllers/employer_home_state.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_home_remote_data_source.dart';
import '../../domain/entities/employer_home_entity.dart';

final employerHomeRemoteDataSourceProvider =
    Provider<EmployerHomeRemoteDataSource>((ref) {
      return EmployerHomeRemoteDataSource(ref.read(supabaseClientProvider));
    });

final employerHomeRepositoryProvider = Provider<EmployerHomeRepository>((ref) {
  return EmployerHomeRepositoryImpl(
    ref.read(employerHomeRemoteDataSourceProvider),
  );
});

final employerHomeProvider = FutureProvider<EmployerHomeEntity>((ref) {
  return ref.read(employerHomeRepositoryProvider).getHomeData();
});

// ==================================================================
// Home CONTROLLER
// ==================================================================

final employerHomeControllerProvider =
    NotifierProvider<EmployerHomeController, EmployerHomeState>(
      EmployerHomeController.new,
    );
