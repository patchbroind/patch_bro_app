import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

class EmployerWorkerDetailsHero extends StatelessWidget {
  const EmployerWorkerDetailsHero({
    super.key,
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkerAvatar(
          worker: worker,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _WorkerBasicInfo(
            worker: worker,
          ),
        ),
      ],
    );
  }
}

class _WorkerAvatar extends StatelessWidget {
  const _WorkerAvatar({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}

class _WorkerBasicInfo extends StatelessWidget {
  const _WorkerBasicInfo({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          worker.name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          worker.profession,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _RatingRow(
          worker: worker,
        ),
        const SizedBox(height: 6),
        _DistanceRow(
          worker: worker,
        ),
        const SizedBox(height: 8),
        _AvailabilityBadge(
          worker: worker,
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          color: AppColors.warning,
          size: 19,
        ),
        const SizedBox(width: 4),
        Text(
          worker.rating.toStringAsFixed(1),
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${worker.reviewCount} reviews)',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DistanceRow extends StatelessWidget {
  const _DistanceRow({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${worker.distanceKm.toStringAsFixed(1)} km from you',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({
    required this.worker,
  });

  final EmployerWorkerEntity worker;

  @override
  Widget build(BuildContext context) {
    final isToday = worker.isAvailableToday;
    final isTomorrow = worker.availableTomorrow;

    final color = isToday
        ? AppColors.success
        : isTomorrow
            ? AppColors.info
            : AppColors.textSecondary;

    final label = isToday
        ? 'Available today'
        : isTomorrow
            ? 'Available tomorrow'
            : 'Currently unavailable';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}