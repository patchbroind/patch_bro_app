import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/network/network_providers.dart';
import 'package:patch_bro/features/employer/profile/data/datasource/employer_profile_remote_data_source.dart';
import 'package:patch_bro/features/employer/profile/data/repositories/employer_profile_repository_impl.dart';

import '../../domain/entities/employer_profile_entity.dart';
import '../../domain/repository/employer_profile_repository.dart';
import '../controllers/employer_profile_controller.dart';
import '../controllers/employer_profile_state.dart';

final employerProfileRemoteDataSourceProvider = Provider<EmployerProfileRemoteDataSource>((ref) {
  return EmployerProfileRemoteDataSource(ref.read(apiClientProvider));
});

final employerProfileRepositoryProvider = Provider<EmployerProfileRepository>((ref) {
  return EmployerProfileRepositoryImpl(ref.read(employerProfileRemoteDataSourceProvider));
});

final employerProfileProvider = FutureProvider<EmployerProfileEntity>((ref) {
  return ref.read(employerProfileRepositoryProvider).getEmployerProfile();
});

final employerProfileControllerProvider =
    NotifierProvider<EmployerProfileController, EmployerProfileState>(
      EmployerProfileController.new,
    );
