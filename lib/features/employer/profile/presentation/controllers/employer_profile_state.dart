import 'package:flutter/foundation.dart';

import '../../domain/entities/employer_profile_entity.dart';

enum EmployerProfileStatus {
  initial,
  loading,
  success,
  failure,
}

@immutable
class EmployerProfileState {
  const EmployerProfileState({
    this.status = EmployerProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final EmployerProfileStatus status;
  final EmployerProfileEntity? profile;
  final String? errorMessage;

  bool get isInitial => status == EmployerProfileStatus.initial;

  bool get isLoading => status == EmployerProfileStatus.loading;

  bool get isSuccess => status == EmployerProfileStatus.success;

  bool get isFailure => status == EmployerProfileStatus.failure;

  bool get hasProfile => profile != null;

  EmployerProfileState copyWith({
    EmployerProfileStatus? status,
    EmployerProfileEntity? profile,
    String? errorMessage,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return EmployerProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : profile ?? this.profile,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  factory EmployerProfileState.initial() {
    return const EmployerProfileState();
  }
}