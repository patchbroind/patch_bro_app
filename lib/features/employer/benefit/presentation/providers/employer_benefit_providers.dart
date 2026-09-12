import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_benefit_remote_data_source.dart';
import '../../data/repository/employer_benefit_repository_impl.dart';
import '../../domain/repository/employer_benefit_repository.dart';
import '../controllers/employer_benefit_controller.dart';
import '../controllers/employer_benefit_state.dart';

final employerBenefitRemoteDataSourceProvider = Provider<EmployerBenefitRemoteDataSource>((ref) {
  return EmployerBenefitRemoteDataSource(ref.read(supabaseClientProvider));
});

final employerBenefitRepositoryProvider = Provider<EmployerBenefitRepository>((ref) {
  return EmployerBenefitRepositoryImpl(ref.read(employerBenefitRemoteDataSourceProvider));
});

final employerBenefitControllerProvider =
    NotifierProvider<EmployerBenefitController, EmployerBenefitState>(
      EmployerBenefitController.new,
    );
