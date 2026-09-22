import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/employer_invitations_repository.dart';
import '../providers/employer_invitations_providers.dart';
import 'employer_invitations_state.dart';

class EmployerInvitationsController
    extends Notifier<EmployerInvitationsState> {
  EmployerInvitationsController(this._jobId);

  final String _jobId;

  late final EmployerInvitationsRepository _repository;

  StreamSubscription<void>? _realtimeSubscription;

  bool _initialized = false;

  @override
  EmployerInvitationsState build() {
    _repository = ref.read(
      employerInvitationsRepositoryProvider,
    );

    ref.onDispose(() {
      _realtimeSubscription?.cancel();
    });

    return const EmployerInvitationsState();
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await load();

    _realtimeSubscription = _repository
        .watchJobInvitations(_jobId)
        .listen((_) {
      load();
    });
  }

  Future<void> load() async {
    state = state.copyWith(
      status: EmployerInvitationsStatus.loading,
      clearError: true,
    );

    try {
      final invitations = await _repository.getJobInvitations(
        _jobId,
      );

      state = state.copyWith(
        status: EmployerInvitationsStatus.success,
        invitations: List.unmodifiable(invitations),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerInvitationsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> inviteWorker(
    String workerId,
  ) async {
    if (state.invitingWorkerId != null) {
      return;
    }

    if (state.activeWorkerIds.contains(workerId)) {
      return;
    }

    if (state.activeCount >= 5) {
      throw Exception(
        'You can invite a maximum of 5 workers at a time.',
      );
    }

    state = state.copyWith(
      invitingWorkerId: workerId,
      clearError: true,
    );

    try {
      await _repository.inviteWorker(
        jobId: _jobId,
        workerId: workerId,
      );

      await load();

      state = state.copyWith(
        clearInvitingWorker: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        clearInvitingWorker: true,
      );

      rethrow;
    }
  }
}