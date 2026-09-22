import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/worker/invitations/presentation/controllers/worker_invitations_state.dart';

import '../../domain/repository/worker_invitations_repository.dart';
import '../providers/worker_invitations_providers.dart';

class WorkerInvitationsController extends Notifier<WorkerInvitationsState> {
  late final WorkerInvitationsRepository _repository;

  StreamSubscription<void>? _subscription;

  @override
  WorkerInvitationsState build() {
    _repository = ref.read(workerInvitationsRepositoryProvider);

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const WorkerInvitationsState();
  }

  Future<void> initialize() async {
    await load();

    await _subscription?.cancel();

    _subscription = _repository.watchInvitations().listen((_) {
      load();
    });
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final invitations = await _repository.getInvitations();

      state = state.copyWith(
        isLoading: false,
        invitations: List.unmodifiable(invitations),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> accept(String invitationId) async {
    state = state.copyWith(respondingInvitationId: invitationId, clearError: true);

    try {
      await _repository.acceptInvitation(invitationId);

      await load();

      state = state.copyWith(clearResponding: true);
    } catch (error) {
      state = state.copyWith(clearResponding: true, errorMessage: error.toString());

      rethrow;
    }
  }

  Future<void> reject(String invitationId) async {
    state = state.copyWith(respondingInvitationId: invitationId, clearError: true);

    try {
      await _repository.rejectInvitation(invitationId);

      await load();

      state = state.copyWith(clearResponding: true);
    } catch (error) {
      state = state.copyWith(clearResponding: true, errorMessage: error.toString());

      rethrow;
    }
  }
}
