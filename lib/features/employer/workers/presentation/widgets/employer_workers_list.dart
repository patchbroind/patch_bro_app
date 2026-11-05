import 'package:flutter/material.dart';

import 'package:patch_bro/core/widgets/app_empty_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_card.dart';

class EmployerWorkerList extends StatelessWidget {
  const EmployerWorkerList({
    super.key,
    required this.state,
    required this.onWorkerTap,
    required this.onFavouriteTap,
    this.onInviteTap,
    this.showInviteButton = false,
    this.invitingWorkerId,
    this.invitedWorkerIds = const {},
  });

  final EmployerWorkersState state;

  final ValueChanged<String> onWorkerTap;

  final ValueChanged<String> onFavouriteTap;

  final ValueChanged<String>? onInviteTap;

  final bool showInviteButton;

  final String? invitingWorkerId;

  final Set<String> invitedWorkerIds;

  @override
  Widget build(BuildContext context) {
    final workers = state.visibleWorkers;

    if (workers.isEmpty) {
      return const AppEmptyState(
        title: 'No workers found',
        message: 'Try changing your search or filters.',
        icon: Icons.people_outline_rounded,
        iconSize: 54,
        padding: EdgeInsets.symmetric(vertical: 90),
      );
    }

    return Column(
      children: [
        for (final worker in workers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EmployerWorkerCard(
              worker: worker,
              onTap: () => onWorkerTap(worker.id),
              onToggleFavourite: () => onFavouriteTap(worker.id),
              onInvite: onInviteTap == null
                  ? null
                  : () => onInviteTap!(worker.id),
              showInviteButton: showInviteButton,
              isInviting: invitingWorkerId == worker.id,
              isInvited: invitedWorkerIds.contains(worker.id),
              isToggling: state.togglingWorkerId == worker.id,
            ),
          ),
      ],
    );
  }
}
