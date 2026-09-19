import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/features/worker/profile/domain/repository/worker_profile_repository.dart';

import '../providers/worker_profile_providers.dart';
import 'worker_profile_state.dart';

class WorkerProfileController
    extends Notifier<WorkerProfileState> {
  WorkerProfileRepository get _repository {
    return ref.read(workerProfileRepositoryProvider);
  }

  @override
  WorkerProfileState build() {
    return const WorkerProfileState();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadProfile() async {
    if (state.isLoading || state.isSaving) {
      return;
    }

    state = state.copyWith(
      status: WorkerProfileStatus.loading,
      clearError: true,
    );

    try {
      final profile =
          await _repository.getCurrentProfile();

      state = state.copyWith(
        status: WorkerProfileStatus.success,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: WorkerProfileStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<bool> saveProfile({
    required String profession,
    required List<String> skills,
    required String about,
    required int experienceYears,
    required List<String> availabilityDays,
    required bool availableToday,
    required bool availableTomorrow,
  }) async {
    if (state.isSaving) {
      return false;
    }

    state = state.copyWith(
      status: WorkerProfileStatus.saving,
      clearError: true,
    );

    try {
      await _repository.saveProfile(
        profession: profession,
        skills: skills,
        about: about,
        experienceYears: experienceYears,
        availabilityDays: availabilityDays,
        availableToday: availableToday,
        availableTomorrow: availableTomorrow,
      );

      final profile =
          await _repository.getCurrentProfile();

      state = state.copyWith(
        status: WorkerProfileStatus.success,
        profile: profile,
        clearError: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        status: WorkerProfileStatus.failure,
        errorMessage: error.toString(),
      );

      return false;
    }
  }
}