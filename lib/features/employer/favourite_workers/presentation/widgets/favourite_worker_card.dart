import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_tappable_card.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';

import '../../domain/entities/favourite_worker_entity.dart';

class FavouriteWorkerCard extends StatelessWidget {
  const FavouriteWorkerCard({
    super.key,
    required this.worker,
    required this.onTap,
    required this.onToggleFavourite,
    this.isToggling = false,
  });

  final FavouriteWorkerEntity worker;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;
  final bool isToggling;

  @override
  Widget build(BuildContext context) {
    final rating = worker.rating;
    final reviewCount = worker.reviewCount;
    final reviewLabel = reviewCount == null
        ? 'No reviews'
        : '$reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}';

    return Container(
      decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
      child: AppTappableCard(
        onTap: onTap,
        color: AppColors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileAvatarWidget(size: 56, name: worker.name, imageUrl: worker.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    worker.profession,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                      Text(
                        rating?.toStringAsFixed(1) ?? 'Not rated',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '($reviewLabel)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Remove favourite',
              onPressed: isToggling ? null : onToggleFavourite,
              icon: isToggling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite_rounded, color: AppColors.error),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
