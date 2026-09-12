import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_benefit_repository.dart';
import '../providers/employer_benefit_providers.dart';
import 'employer_benefit_state.dart';

class EmployerBenefitController extends Notifier<EmployerBenefitState> {
  EmployerBenefitRepository get _repository {
    return ref.read(employerBenefitRepositoryProvider);
  }

  @override
  EmployerBenefitState build() {
    return const EmployerBenefitState();
  }

  Future<void> loadBenefitDetails() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(status: EmployerBenefitStatus.loading, clearError: true);

    try {
      final benefit = await _repository.getBenefitDetails();
      state = state.copyWith(
        status: EmployerBenefitStatus.success,
        benefit: benefit,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(status: EmployerBenefitStatus.failure, errorMessage: error.toString());
    }
  }

  Future<void> refreshBenefitDetails() async {
    try {
      final benefit = await _repository.getBenefitDetails();
      state = state.copyWith(
        status: EmployerBenefitStatus.success,
        benefit: benefit,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(status: EmployerBenefitStatus.failure, errorMessage: error.toString());
    }
  }
}
