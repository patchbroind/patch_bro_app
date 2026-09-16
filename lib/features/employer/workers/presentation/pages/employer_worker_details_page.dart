import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/workers/presentation/providers/employer_workers_providers.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_availability.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_hero.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_invite_bar.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_review_card.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_section_title.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_skills.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_details_stats.dart';

class EmployerWorkerDetailsPage extends ConsumerWidget {
  const EmployerWorkerDetailsPage({super.key, required this.workerId});

  final String workerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(employerWorkersControllerProvider);

    final worker = ref
        .read(employerWorkersControllerProvider.notifier)
        .workerById(workerId);

    if (worker == null) {
      return const Scaffold(body: Center(child: Text('Worker not found')));
    }

    return Scaffold(
      appBar: _buildAppBar(context, ref, worker.isFavourite),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmployerWorkerDetailsHero(worker: worker),
              const SizedBox(height: 18),
              EmployerWorkerDetailsStats(worker: worker),
              const SizedBox(height: 24),
              EmployerWorkerDetailsSectionTitle(title: 'About'),
              const SizedBox(height: 8),
              _AboutText(text: worker.about),
              const SizedBox(height: 22),
              EmployerWorkerDetailsSectionTitle(title: 'Skills'),
              const SizedBox(height: 10),
              EmployerWorkerDetailsSkills(worker: worker),
              const SizedBox(height: 22),
              EmployerWorkerDetailsSectionTitle(title: 'Availability'),
              const SizedBox(height: 10),
              EmployerWorkerDetailsAvailability(worker: worker),
              const SizedBox(height: 22),
              EmployerWorkerDetailsSectionTitle(
                title: 'Reviews',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ),
              const SizedBox(height: 8),
              const EmployerWorkerDetailsReviewCard(),
              const SizedBox(height: 12),
              const EmployerWorkerDetailsReviewCard(
                reviewer: 'Fahad P',
                text: 'Very professional and completed the work on time.',
              ),
            ],
          ),
        ),
      ),
      bottomSheet: EmployerWorkerDetailsInviteBar(
        onInvite: () => _handleInvite(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isFavourite,
  ) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      title: const Text('Worker Details'),
      actions: [
        IconButton(
          onPressed: () {
            ref
                .read(employerWorkersControllerProvider.notifier)
                .toggleFavourite(workerId);
          },
          icon: Icon(
            isFavourite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isFavourite ? AppColors.error : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _handleInvite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite flow will be connected to the job backend next.'),
      ),
    );
  }
}

class _AboutText extends StatelessWidget {
  const _AboutText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}
