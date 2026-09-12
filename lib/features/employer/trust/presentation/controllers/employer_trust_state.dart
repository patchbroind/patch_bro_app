import 'package:flutter/foundation.dart';

import '../../domain/entities/employer_trust_entity.dart';

enum EmployerTrustStatus { initial, loading, success, failure }

@immutable
class EmployerTrustState {
  const EmployerTrustState({
    this.status = EmployerTrustStatus.initial,
    this.trust,
    this.errorMessage,
  });

  final EmployerTrustStatus status;
  final EmployerTrustEntity? trust;
  final String? errorMessage;

  bool get isInitial => status == EmployerTrustStatus.initial;
  bool get isLoading => status == EmployerTrustStatus.loading;
  bool get isSuccess => status == EmployerTrustStatus.success;
  bool get isFailure => status == EmployerTrustStatus.failure;
  bool get hasTrustDetails => trust != null;

  EmployerTrustState copyWith({
    EmployerTrustStatus? status,
    EmployerTrustEntity? trust,
    String? errorMessage,
    bool clearTrust = false,
    bool clearError = false,
  }) {
    return EmployerTrustState(
      status: status ?? this.status,
      trust: clearTrust ? null : trust ?? this.trust,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
