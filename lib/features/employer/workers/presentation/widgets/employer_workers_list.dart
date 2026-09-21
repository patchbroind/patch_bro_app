import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_card.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_workers_empty_state.dart';

class EmployerWorkerList
    extends StatelessWidget {
  const EmployerWorkerList({super.key, 
    required this.state,
    required this.onWorkerTap,
    required this.onFavouriteTap,
  });

  final EmployerWorkersState state;

  final ValueChanged<String>
      onWorkerTap;

  final ValueChanged<String>
      onFavouriteTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final workers =
        state.visibleWorkers;

    if (workers.isEmpty) {
      return EmployerWorkersEmptyState(
      );
    }

    return Column(
      children: [
        for (final worker in workers)
          Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child:
                EmployerWorkerCard(
              worker: worker,
              onTap: () =>
                  onWorkerTap(
                worker.id,
              ),
              onToggleFavourite:
                  () =>
                      onFavouriteTap(
                worker.id,
              ),
              isToggling:
                  state.togglingWorkerId ==
                      worker.id,
            ),
          ),
      ],
    );
  }
}