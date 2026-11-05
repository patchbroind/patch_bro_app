import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/invitation_response_action.dart';

import '../../domain/repository/worker_home_repository.dart';
import '../providers/worker_home_providers.dart';
import 'worker_home_state.dart';

class WorkerHomeController extends Notifier<WorkerHomeState> {
  late final WorkerHomeRepository _repository;

  @override
  WorkerHomeState build() {
    _repository = ref.read(workerHomeRepositoryProvider);
    return const WorkerHomeState();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final jobs = await _repository.getAssignedJobs();

      state = state.copyWith(
        isLoading: false,
        jobs: List.unmodifiable(jobs),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  // Future<void> respondToInvitation({
  //   required String invitationId,
  //   required InvitationResponseAction action,
  //   required Future<void> Function(String invitationId) onRespond,
  // }) async {
  //   // Prevent multiple simultaneous invitation responses.
  //   if (state.isRespondingToInvitation) return;

  //   state = state.copyWith(
  //     respondingInvitationId: invitationId,
  //     respondingAction: action,
  //     clearError: true,
  //   );

  //   try {
  //     await onRespond(invitationId);
  //   } catch (error) {
  //     state = state.copyWith(
  //       errorMessage: error.toString(),
  //     );
  //     rethrow;
  //   } finally {
  //     state = state.copyWith(
  //       clearRespondingInvitation: true,
  //     );
  //   }
  // }
}