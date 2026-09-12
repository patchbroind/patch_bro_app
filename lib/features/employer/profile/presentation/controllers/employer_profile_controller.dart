import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_profile_repository.dart';
import '../providers/employer_profile_providers.dart';
import 'employer_profile_state.dart';

class EmployerProfileController
    extends Notifier<EmployerProfileState> {
  EmployerProfileRepository get _repository {
    return ref.read(employerProfileRepositoryProvider);
  }

  @override
  EmployerProfileState build() {
    return EmployerProfileState.initial();
  }

  Future<void> loadProfile() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      status: EmployerProfileStatus.loading,
      clearError: true,
    );

    try {
      final profile = await _repository.getEmployerProfile();

      state = state.copyWith(
        status: EmployerProfileStatus.success,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerProfileStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _repository.getEmployerProfile();

      state = state.copyWith(
        status: EmployerProfileStatus.success,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerProfileStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}