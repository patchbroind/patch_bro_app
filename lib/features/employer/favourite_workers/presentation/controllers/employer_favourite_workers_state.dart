import 'package:flutter/foundation.dart';

import '../../domain/entities/favourite_worker_entity.dart';

enum EmployerFavouriteWorkersStatus { initial, loading, success, failure }

@immutable
class EmployerFavouriteWorkersState {
  const EmployerFavouriteWorkersState({
    this.status = EmployerFavouriteWorkersStatus.initial,
    this.favouriteWorkers = const [
     
    ],
    this.errorMessage,
    this.togglingWorkerId,
  });

  final EmployerFavouriteWorkersStatus status;
  final List<FavouriteWorkerEntity> favouriteWorkers;
  final String? errorMessage;
  final String? togglingWorkerId;

  bool get isLoading => status == EmployerFavouriteWorkersStatus.loading;
  bool get isSuccess => status == EmployerFavouriteWorkersStatus.success;
  bool get isFailure => status == EmployerFavouriteWorkersStatus.failure;
  bool get hasWorkers => favouriteWorkers.isNotEmpty;

  EmployerFavouriteWorkersState copyWith({
    EmployerFavouriteWorkersStatus? status,
    List<FavouriteWorkerEntity>? favouriteWorkers,
    String? errorMessage,
    String? togglingWorkerId,
    bool clearError = false,
    bool clearTogglingWorker = false,
  }) {
    return EmployerFavouriteWorkersState(
      status: status ?? this.status,
      favouriteWorkers: favouriteWorkers ?? this.favouriteWorkers,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      togglingWorkerId: clearTogglingWorker ? null : togglingWorkerId ?? this.togglingWorkerId,
    );
  }
}
