import 'package:flutter/foundation.dart';

import '../../domain/entities/employer_benefit_entity.dart';

enum EmployerBenefitStatus { initial, loading, success, failure }

@immutable
class EmployerBenefitState {
  const EmployerBenefitState({
    this.status = EmployerBenefitStatus.initial,
    this.benefit,
    this.errorMessage,
  });

  final EmployerBenefitStatus status;
  final EmployerBenefitEntity? benefit;
  final String? errorMessage;

  bool get isLoading => status == EmployerBenefitStatus.loading;
  bool get isSuccess => status == EmployerBenefitStatus.success;
  bool get isFailure => status == EmployerBenefitStatus.failure;
  bool get hasBenefit => benefit != null;

  EmployerBenefitState copyWith({
    EmployerBenefitStatus? status,
    EmployerBenefitEntity? benefit,
    String? errorMessage,
    bool clearBenefit = false,
    bool clearError = false,
  }) {
    return EmployerBenefitState(
      status: status ?? this.status,
      benefit: clearBenefit ? null : benefit ?? this.benefit,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
