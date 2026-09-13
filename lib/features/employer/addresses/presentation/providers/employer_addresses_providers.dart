import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_addresses_remote_data_source.dart';
import '../../data/repository/employer_addresses_repository_impl.dart';
import '../../domain/repository/employer_addresses_repository.dart';
import '../controllers/employer_addresses_controller.dart';
import '../controllers/employer_addresses_state.dart';

final employerAddressesRemoteDataSourceProvider = Provider<EmployerAddressesRemoteDataSource>((
  ref,
) {
  return EmployerAddressesRemoteDataSource(ref.read(supabaseClientProvider));
});

final employerAddressesRepositoryProvider = Provider<EmployerAddressesRepository>((ref) {
  return EmployerAddressesRepositoryImpl(ref.read(employerAddressesRemoteDataSourceProvider));
});

final employerAddressesControllerProvider =
    NotifierProvider<EmployerAddressesController, EmployerAddressesState>(
      EmployerAddressesController.new,
    );
