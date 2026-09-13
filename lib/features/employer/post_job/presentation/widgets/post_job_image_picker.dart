import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';


class PostJobImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const PostJobImagePicker({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Job Images',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '${images.length}/2',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ...List.generate(
              images.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index == images.length - 1
                      ? 0
                      : 12,
                ),
                child: _ImageTile(
                  image: images[index],
                  onRemove: () => onRemove(index),
                ),
              ),
            ),
            if (images.length < 2)
              _AddImageTile(
                onTap: onAdd,
              ),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            image,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageTile({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: AppColors.employerLight.withValues(
            alpha: 0.45,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.employerPrimary.withValues(
              alpha: 0.35,
            ),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.employerPrimary,
              size: 28,
            ),
            SizedBox(height: 5),
            Text(
              'Add photo',
              style: TextStyle(
                color: AppColors.employerPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}