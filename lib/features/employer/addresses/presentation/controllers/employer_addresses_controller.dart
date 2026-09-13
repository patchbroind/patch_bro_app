import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_addresses_repository.dart';
import '../providers/employer_addresses_providers.dart';
import 'employer_addresses_state.dart';

class EmployerAddressesController extends Notifier<EmployerAddressesState> {
  EmployerAddressesRepository get _repository {
    return ref.read(employerAddressesRepositoryProvider);
  }

  @override
  EmployerAddressesState build() {
    return const EmployerAddressesState();
  }

  Future<void> loadAddresses() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(status: EmployerAddressesStatus.loading, clearError: true);

    try {
      final addresses = await _repository.getAddresses();
      state = state.copyWith(
        status: EmployerAddressesStatus.success,
        addresses: List.unmodifiable(addresses),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerAddressesStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshAddresses() async {
    try {
      final addresses = await _repository.getAddresses();
      state = state.copyWith(
        status: EmployerAddressesStatus.success,
        addresses: List.unmodifiable(addresses),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: state.hasAddresses
            ? EmployerAddressesStatus.success
            : EmployerAddressesStatus.failure,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }
}
