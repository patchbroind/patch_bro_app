
import 'package:flutter/foundation.dart';

@immutable
class WorkerJobProgressState {
  const WorkerJobProgressState({
    this.status = 'not_started',
    this.isLoading = false,
    this.errorMessage,
  });

  final String status;
  final bool isLoading;
  final String? errorMessage;

  WorkerJobProgressState copyWith({
    String? status,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkerJobProgressState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
