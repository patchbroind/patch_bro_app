import 'package:flutter/foundation.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';


enum EmployerWorkersTab {
  workers,
  favourites,
}

enum EmployerWorkersStatus {
  initial,
  loading,
  success,
  failure,
}

@immutable
class EmployerWorkersFilters {
  const EmployerWorkersFilters({
    this.category = 'All',
    this.distanceKm = 10,
    this.minimumRating = 0,
    this.availability = 'Any time',
    this.experience = 'Any',
    this.verifiedOnly = false,
    this.currentlyAvailableOnly = false,
  });

  final String category;
  final double distanceKm;
  final double minimumRating;
  final String availability;
  final String experience;
  final bool verifiedOnly;
  final bool currentlyAvailableOnly;

  EmployerWorkersFilters copyWith({
    String? category,
    double? distanceKm,
    double? minimumRating,
    String? availability,
    String? experience,
    bool? verifiedOnly,
    bool? currentlyAvailableOnly,
  }) {
    return EmployerWorkersFilters(
      category: category ?? this.category,
      distanceKm: distanceKm ?? this.distanceKm,
      minimumRating: minimumRating ?? this.minimumRating,
      availability: availability ?? this.availability,
      experience: experience ?? this.experience,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      currentlyAvailableOnly:
          currentlyAvailableOnly ?? this.currentlyAvailableOnly,
    );
  }
}

@immutable
class EmployerWorkersState {
  const EmployerWorkersState({
    this.status = EmployerWorkersStatus.initial,
    this.workers = const [],
    this.searchQuery = '',
    this.selectedTab = EmployerWorkersTab.workers,
    this.selectedCategory = 'All',
    this.filters = const EmployerWorkersFilters(),
    this.errorMessage,
    this.togglingWorkerId,
  });

  final EmployerWorkersStatus status;
  final List<EmployerWorkerEntity> workers;

  final String searchQuery;
  final EmployerWorkersTab selectedTab;
  final String selectedCategory;

  final EmployerWorkersFilters filters;

  final String? errorMessage;
  final String? togglingWorkerId;

  bool get isLoading => status == EmployerWorkersStatus.loading;

  bool get isSuccess => status == EmployerWorkersStatus.success;

  bool get isFailure => status == EmployerWorkersStatus.failure;

  bool get hasWorkers => workers.isNotEmpty;

  List<EmployerWorkerEntity> get favouriteWorkers {
    return workers
        .where((worker) => worker.isFavourite)
        .toList(growable: false);
  }

  List<EmployerWorkerEntity> get visibleWorkers {
    final query = searchQuery.trim().toLowerCase();

    Iterable<EmployerWorkerEntity> result = selectedTab ==
            EmployerWorkersTab.workers
        ? workers
        : favouriteWorkers;

    if (query.isNotEmpty) {
      result = result.where((worker) {
        final searchableText = [
          worker.name,
          worker.profession,
          ...worker.skills,
        ].join(' ').toLowerCase();

        return searchableText.contains(query);
      });
    }

    if (selectedCategory != 'All') {
      result = result.where(
        (worker) =>
            worker.profession.toLowerCase() ==
            selectedCategory.toLowerCase(),
      );
    }

    if (filters.distanceKm > 0) {
      result = result.where(
        (worker) => worker.distanceKm <= filters.distanceKm,
      );
    }

    if (filters.minimumRating > 0) {
      result = result.where(
        (worker) => worker.rating >= filters.minimumRating,
      );
    }

    switch (filters.availability) {
      case 'Available today':
        result = result.where((worker) => worker.isAvailableToday);
        break;

      case 'Available tomorrow':
        result = result.where((worker) => worker.availableTomorrow);
        break;

      case 'Any time':
      default:
        break;
    }

    switch (filters.experience) {
      case '1+ years':
        result = result.where((worker) => worker.experienceYears >= 1);
        break;

      case '3+ years':
        result = result.where((worker) => worker.experienceYears >= 3);
        break;

      case '5+ years':
        result = result.where((worker) => worker.experienceYears >= 5);
        break;

      case 'Any':
      default:
        break;
    }

    if (filters.currentlyAvailableOnly) {
      result = result.where((worker) => worker.isAvailableToday);
    }

    return result.toList(growable: false);
  }

  int get activeFilterCount {
    var count = 0;

    if (filters.distanceKm != 10) {
      count++;
    }

    if (filters.minimumRating > 0) {
      count++;
    }

    if (filters.availability != 'Any time') {
      count++;
    }

    if (filters.experience != 'Any') {
      count++;
    }

    if (filters.verifiedOnly) {
      count++;
    }

    if (filters.currentlyAvailableOnly) {
      count++;
    }

    return count;
  }

  EmployerWorkersState copyWith({
    EmployerWorkersStatus? status,
    List<EmployerWorkerEntity>? workers,
    String? searchQuery,
    EmployerWorkersTab? selectedTab,
    String? selectedCategory,
    EmployerWorkersFilters? filters,
    String? errorMessage,
    String? togglingWorkerId,
    bool clearError = false,
    bool clearTogglingWorker = false,
  }) {
    return EmployerWorkersState(
      status: status ?? this.status,
      workers: workers ?? this.workers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filters: filters ?? this.filters,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      togglingWorkerId: clearTogglingWorker
          ? null
          : togglingWorkerId ?? this.togglingWorkerId,
    );
  }
}