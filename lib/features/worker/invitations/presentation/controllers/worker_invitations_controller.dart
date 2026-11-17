import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/invitations/presentation/controllers/worker_invitations_state.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/shared/invitations/domain/entities/realtime_sync_event.dart';

import '../../domain/repository/worker_invitations_repository.dart';
import '../providers/worker_invitations_providers.dart';

class WorkerInvitationsController
    extends Notifier<WorkerInvitationsState> {
  late final WorkerInvitationsRepository _repository;

  StreamSubscription<RealtimeSyncEvent>? _subscription;
  Timer? _eventTimer;
  Timer? _reconnectTimer;
  Future<void>? _activeFetch;
  bool _fetchQueued = false;
  bool _disposed = false;
  bool _initialized = false;
  int _fetchGeneration = 0;
  String? _workerId;

  @override
  WorkerInvitationsState build() {
    _repository = ref.read(workerInvitationsRepositoryProvider);
    _workerId = ref.read(currentUserProvider)?.id;

    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      _workerId = next?.id;
      _initialized = false;
      _fetchGeneration++;
      _eventTimer?.cancel();
      _reconnectTimer?.cancel();
      _subscription?.cancel();
      _subscription = null;
      state = const WorkerInvitationsState();
      if (next != null) initialize();
    });

    ref.onDispose(() {
      _disposed = true;
      _eventTimer?.cancel();
      _subscription?.cancel();
    });

    return const WorkerInvitationsState();
  }

  Future<void> initialize() async {
    if (_workerId == null) {
      _workerId = ref.read(currentUserProvider)?.id;
      if (_workerId == null) return;
    }
    if (_initialized) return;
    _initialized = true;
    await _subscription?.cancel();
    _subscription = _repository.watchInvitations().listen(
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
    if (_disposed || _workerId == null || _reconnectTimer?.isActive == true) return;
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _initialized = false;
      if (!_disposed) initialize();
    });
  }

  Future<void> _fetchLatest() async {
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      isLoading: state.invitations.isEmpty,
      clearError: true,
    );

    try {
      final invitations = await _repository.getInvitations();
      if (_disposed || generation != _fetchGeneration) return;

      state = state.copyWith(
        isLoading: false,
        invitations: List.unmodifiable(invitations),
        clearError: true,
      );
    } catch (error) {
      if (_disposed || generation != _fetchGeneration) return;
      state = state.copyWith(
        isLoading: false,
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

  Future<void> accept(String invitationId) {
    return _respond(
      invitationId,
      InvitationResponseAction.accept,
    );
  }

  Future<void> reject(String invitationId) {
    return _respond(
      invitationId,
      InvitationResponseAction.decline,
    );
  }

  Future<void> _respond(
    String invitationId,
    InvitationResponseAction action,
  ) async {
    if (state.isRespondingToInvitation) return;

    state = state.copyWith(
      respondingInvitationId: invitationId,
      respondingAction: action,
      clearError: true,
    );

    try {
      if (action == InvitationResponseAction.accept) {
        await _repository.acceptInvitation(invitationId);
      } else {
        await _repository.rejectInvitation(invitationId);
      }

      await load();
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
      );

      rethrow;
    } finally {
      state = state.copyWith(
        clearResponding: true,
      );
    }
  }
}
