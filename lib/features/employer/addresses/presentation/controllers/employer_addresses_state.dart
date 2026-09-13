import 'package:flutter/foundation.dart';

import '../../domain/entities/employer_address_entity.dart';

enum EmployerAddressesStatus { initial, loading, success, failure }

@immutable
class EmployerAddressesState {
  const EmployerAddressesState({
    this.status = EmployerAddressesStatus.initial,
    this.addresses = const [],
    this.errorMessage,
  });

  final EmployerAddressesStatus status;
  final List<EmployerAddressEntity> addresses;
  final String? errorMessage;

  bool get isLoading => status == EmployerAddressesStatus.loading;
  bool get isFailure => status == EmployerAddressesStatus.failure;
  bool get hasAddresses => addresses.isNotEmpty;

  EmployerAddressesState copyWith({
    EmployerAddressesStatus? status,
    List<EmployerAddressEntity>? addresses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmployerAddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
