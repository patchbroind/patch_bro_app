import 'package:flutter/foundation.dart';
import 'package:patch_bro/features/worker/profile/domain/entities/worker_profile_entity.dart';


enum WorkerProfileStatus {
  initial,
  loading,
  saving,
  success,
  failure,
}

@immutable
class WorkerProfileState {
  const WorkerProfileState({
    this.status = WorkerProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final WorkerProfileStatus status;
  final WorkerProfileEntity? profile;
  final String? errorMessage;

  bool get isLoading =>
      status == WorkerProfileStatus.loading;

  bool get isSaving =>
      status == WorkerProfileStatus.saving;

  bool get isFailure =>
      status == WorkerProfileStatus.failure;

  bool get hasProfile =>
      profile != null;

  WorkerProfileState copyWith({
    WorkerProfileStatus? status,
    WorkerProfileEntity? profile,
    String? errorMessage,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return WorkerProfileState(
      status: status ?? this.status,
      profile: clearProfile
          ? null
          : profile ?? this.profile,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}