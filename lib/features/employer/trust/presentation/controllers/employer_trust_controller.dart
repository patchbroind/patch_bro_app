import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_trust_repository.dart';
import '../providers/employer_trust_providers.dart';
import 'employer_trust_state.dart';

class EmployerTrustController extends Notifier<EmployerTrustState> {
  EmployerTrustRepository get _repository {
    return ref.read(employerTrustRepositoryProvider);
  }

  @override
  EmployerTrustState build() {
    return const EmployerTrustState();
  }

  Future<void> loadTrustDetails() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      status: EmployerTrustStatus.loading,
      clearError: true,
    );

    try {
      final trust = await _repository.getTrustDetails();
      state = state.copyWith(
        status: EmployerTrustStatus.success,
        trust: trust,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerTrustStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshTrustDetails() async {
    try {
      final trust = await _repository.getTrustDetails();
      state = state.copyWith(
        status: EmployerTrustStatus.success,
        trust: trust,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerTrustStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}
