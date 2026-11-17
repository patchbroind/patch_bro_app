import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/shared/invitations/domain/entities/realtime_sync_event.dart';

import '../../domain/repository/employer_invitations_repository.dart';
import '../providers/employer_invitations_providers.dart';
import 'employer_invitations_state.dart';

class EmployerInvitationsController
    extends Notifier<EmployerInvitationsState> {
  EmployerInvitationsController(this._jobId);

  final String _jobId;

  late final EmployerInvitationsRepository _repository;

  StreamSubscription<RealtimeSyncEvent>? _realtimeSubscription;
  Timer? _eventTimer;
  Timer? _reconnectTimer;
  Future<void>? _activeFetch;
  bool _fetchQueued = false;
  bool _disposed = false;
  int _fetchGeneration = 0;

  bool _initialized = false;

  @override
  EmployerInvitationsState build() {
    _repository = ref.read(
      employerInvitationsRepositoryProvider,
    );

    ref.onDispose(() {
      _disposed = true;
      _eventTimer?.cancel();
      _reconnectTimer?.cancel();
      _realtimeSubscription?.cancel();
    });

    return const EmployerInvitationsState();
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository
        .watchJobInvitations(_jobId)
        .listen(
      (event) {
        if (event.isConnected || event.eventType != null) {
          _reconnectTimer?.cancel();
          _scheduleRefresh();
        } else if (event.error != null) {
          state = state.copyWith(errorMessage: 'Invitation realtime error: ${event.error}');
          _scheduleReconnect();
        } else {
          _scheduleReconnect();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        state = state.copyWith(errorMessage: 'Invitation realtime stream failed: $error');
      },
      onDone: () {
        if (!_disposed) {
          _initialized = false;
          state = state.copyWith(errorMessage: 'Invitation realtime connection closed.');
          _scheduleReconnect();
        }
      },
    );
    await load();
    if (state.status == EmployerInvitationsStatus.failure) {
      _initialized = false;
    }
  }

  Future<void> load() async {
    if (_disposed) return;
    if (_activeFetch != null) {
      _fetchQueued = true;
      await _activeFetch;
      return;
    }

    final fetch = _fetchLatest();
    _activeFetch = fetch;
    try {
      await fetch;
    } finally {
      _activeFetch = null;
    }
    if (_fetchQueued && !_disposed) {
      _fetchQueued = false;
      await load();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer?.isActive == true) return;
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _initialized = false;
      if (!_disposed) initialize();
    });
  }

  Future<void> _fetchLatest() async {
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      status: state.invitations.isEmpty
          ? EmployerInvitationsStatus.loading
          : state.status,
      clearError: true,
    );

    try {
      final invitations = await _repository.getJobInvitations(
        _jobId,
      );
      if (_disposed || generation != _fetchGeneration) return;

      state = state.copyWith(
        status: EmployerInvitationsStatus.success,
        invitations: List.unmodifiable(invitations),
        clearError: true,
      );
    } catch (error) {
      if (_disposed || generation != _fetchGeneration) return;
      state = state.copyWith(
        status: EmployerInvitationsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void _scheduleRefresh() {
    _eventTimer?.cancel();
    _eventTimer = Timer(const Duration(milliseconds: 180), () {
      if (!_disposed) load();
    });
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
