import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_network_image.dart';

import 'invitation_detail_card.dart';

class InvitationMediaGallery extends StatelessWidget {
  const InvitationMediaGallery({
    super.key,
    required this.imageUrls,
    this.onImageTap,
  });

  final List<String> imageUrls;
  final ValueChanged<int>? onImageTap;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return InvitationDetailCard(
      icon: Icons.image_outlined,
      title: 'Images (${imageUrls.length})',
      child: SizedBox(
        height: 112,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onImageTap?.call(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppNetworkImage(
                  imageUrl: imageUrls[index],
                  width: 116,
                  height: 112,
                  backgroundColor: WorkerColors.imagePlaceholder,
                  fallback: const Icon(
                    Icons.broken_image_outlined,
                    color: WorkerColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}