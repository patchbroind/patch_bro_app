import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/employer/home/domain/repository/employer_home_repository.dart';
import 'package:patch_bro/features/employer/home/presentation/controllers/employer_home_state.dart';
import 'package:patch_bro/features/employer/home/presentation/providers/employer_home_provider.dart';

import '../../domain/entities/employer_home_entity.dart';

class EmployerHomeController extends Notifier<EmployerHomeState> {
  EmployerHomeRepository get _repository =>
      ref.read(employerHomeRepositoryProvider);

  @override
  EmployerHomeState build() {
    Future.microtask(loadHome);

    return const EmployerHomeState();
  }

  // ================================================================
  // LOAD HOME
  // ================================================================

  Future<void> loadHome() async {
    if (state.status == EmployerHomeStatus.loading) {
      return;
    }

    state = state.copyWith(
      status: EmployerHomeStatus.loading,
      clearError: true,
    );

    try {
      final EmployerHomeEntity data = await _repository.getHomeData();

      state = state.copyWith(
        status: EmployerHomeStatus.success,
        name: data.name,
        avatarUrl: data.avatarUrl,
        location: data.location,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerHomeStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  // ================================================================
  // REFRESH
  // ================================================================

  Future<void> refresh() async {
    await loadHome();
  }

  // ================================================================
  // SEARCH
  // ================================================================

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // ================================================================
  // CAROUSEL
  // ================================================================

  void setCarouselIndex(int index) {
    state = state.copyWith(currentCarouselIndex: index);
  }

  // ================================================================
  // LOCATION PROMPT
  // ================================================================

  void markLocationPromptShown() {
    if (state.locationPromptShown) {
      return;
    }

    state = state.copyWith(locationPromptShown: true);
  }

  // ================================================================
  // UPDATE LOCATION
  // ================================================================

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    if (state.isUpdatingLocation) {
      return false;
    }

    state = state.copyWith(isUpdatingLocation: true, clearError: true);

    try {
      await _repository.updateLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      // Reload profile/home data after
      // successful location update.
      final data = await _repository.getHomeData();

      state = state.copyWith(
        status: EmployerHomeStatus.success,
        name: data.name,
        avatarUrl: data.avatarUrl,
        location: data.location,
        isUpdatingLocation: false,
        clearError: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isUpdatingLocation: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }
}
