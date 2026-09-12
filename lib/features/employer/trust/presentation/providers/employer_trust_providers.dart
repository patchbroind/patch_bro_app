import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_trust_remote_data_source.dart';
import '../../data/repository/employer_trust_repository_impl.dart';
import '../../domain/repository/employer_trust_repository.dart';
import '../controllers/employer_trust_controller.dart';
import '../controllers/employer_trust_state.dart';

final employerTrustRemoteDataSourceProvider = Provider<EmployerTrustRemoteDataSource>((ref) {
  return EmployerTrustRemoteDataSource(ref.read(supabaseClientProvider));
});

final employerTrustRepositoryProvider = Provider<EmployerTrustRepository>((ref) {
  return EmployerTrustRepositoryImpl(ref.read(employerTrustRemoteDataSourceProvider));
});

final employerTrustControllerProvider =
    NotifierProvider<EmployerTrustController, EmployerTrustState>(EmployerTrustController.new);
