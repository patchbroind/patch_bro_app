import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';
import 'package:patch_bro/features/worker/invitations/presentation/controllers/worker_invitations_state.dart';

import '../../domain/repository/worker_invitations_repository.dart';
import '../providers/worker_invitations_providers.dart';

class WorkerInvitationsController
    extends Notifier<WorkerInvitationsState> {
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
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final invitations = await _repository.getInvitations();

      state = state.copyWith(
        isLoading: false,
        invitations: List.unmodifiable(invitations),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
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