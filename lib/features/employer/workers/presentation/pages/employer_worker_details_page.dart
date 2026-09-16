import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

import '../providers/employer_workers_providers.dart';

class EmployerWorkerDetailsPage extends ConsumerWidget {
  const EmployerWorkerDetailsPage({
    super.key,
    required this.workerId,
  });

  final String workerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref
        .watch(employerWorkersControllerProvider)
        .workers
        .where((worker) => worker.id == workerId)
        .firstOrNull;

    if (worker == null) {
      return const Scaffold(
        body: Center(
          child: Text('Worker not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
                  .toggleFavourite(worker.id);
            },
            icon: Icon(
              worker.isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: worker.isFavourite
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WorkerHero(worker: worker),
              const SizedBox(height: 18),
              _StatsSection(worker: worker),
              const SizedBox(height: 24),
              _SectionTitle(title: 'About'),
              const SizedBox(height: 8),
              Text(
                worker.about,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 22),
              _SectionTitle(title: 'Skills'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: worker.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      skill,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              _SectionTitle(title: 'Availability'),
              const SizedBox(height: 10),
              _AvailabilitySection(worker: worker),
              const SizedBox(height: 22),
              _SectionTitle(
                title: 'Reviews',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ),
              const SizedBox(height: 8),
              const _DummyReviewCard(),
              const SizedBox(height: 12),
              const _DummyReviewCard(
                reviewer: 'Fahad P',
                text:
                    'Very professional and completed the work on time.',
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          color: AppColors.white,
          child: AppPrimaryButton(
            label: 'Invite for Job',
            backgroundColor: AppColors.employerPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Invite flow will be connected to the job backend next.',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WorkerHero extends StatelessWidget {
  const _WorkerHero({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ProfileAvatarWidget(
                size: 96,
                name: worker.name,
                imageUrl: worker.avatarUrl,
              ),
            ),
            if (worker.isAvailableToday)
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                worker.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                worker.profession,
                style:
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    worker.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${worker.reviewCount} reviews)',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${worker.distanceKm.toStringAsFixed(1)} km from you',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  worker.isAvailableToday
                      ? 'Available today'
                      : worker.availableTomorrow
                          ? 'Available tomorrow'
                          : 'Currently unavailable',
                  style:
                      Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: worker.isAvailableToday
                                ? AppColors.success
                                : worker.availableTomorrow
                                    ? AppColors.info
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${worker.experienceYears}+',
            label: 'Years Experience',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '${worker.jobsCompleted}',
            label: 'Jobs Completed',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '${worker.responseRate}%',
            label: 'Response Rate',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Row(
      children: days.map((day) {
        final available = worker.availabilityDays.contains(day);

        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 5),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: available
                  ? AppColors.employerLight
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 3),
                Icon(
                  available
                      ? Icons.check_rounded
                      : Icons.remove_rounded,
                  size: 15,
                  color: available
                      ? AppColors.employerPrimary
                      : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DummyReviewCard extends StatelessWidget {
  const _DummyReviewCard({
    this.reviewer = 'Akhil Varma',
    this.text =
        'Excellent work! Very professional and completed the job on time.',
  });

  final String reviewer;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reviewer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 2),
              const Text('5.0'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

extension on Iterable<EmployerWorkerEntity> {
  EmployerWorkerEntity? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}