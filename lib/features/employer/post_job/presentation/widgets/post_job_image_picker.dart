import 'dart:io';

import 'package:flutter/material.dart';

class PostJobImagePicker extends StatelessWidget {
  const PostJobImagePicker({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.existingImages = const [],
    this.onRemoveExisting,
  });

  /// Newly selected local images.
  final List<File> images;

  /// Existing remote images from the server.
  final List<String> existingImages;

  final VoidCallback onAdd;

  /// Removes a newly selected local image.
  final ValueChanged<int> onRemove;

  /// Removes an existing server image.
  final ValueChanged<int>? onRemoveExisting;

  int get totalImageCount => existingImages.length + images.length;

  bool get canAdd => totalImageCount < 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        Text('Add up to 2 images', style: Theme.of(context).textTheme.bodySmall),

        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // ---------------------------------------------------------------
            // EXISTING SERVER IMAGES
            // ---------------------------------------------------------------

            ...List.generate(existingImages.length, (index) {
              return _ImageTile(
                onRemove: onRemoveExisting == null
                    ? null
                    : () {
                        onRemoveExisting!(index);
                      },
                child: Image.network(
                  existingImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image_outlined));
                  },
                ),
              );
            }),

            // ---------------------------------------------------------------
            // NEW LOCAL IMAGES
            // ---------------------------------------------------------------
            ...List.generate(images.length, (index) {
              return _ImageTile(
                child: Image.file(images[index], fit: BoxFit.cover),
                onRemove: () {
                  onRemove(index);
                },
              );
            }),

            // ---------------------------------------------------------------
            // ADD BUTTON
            // ---------------------------------------------------------------
            if (canAdd)
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 28),
                      SizedBox(height: 6),
                      Text('Add'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 96, height: 96, child: child),
        ),

        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
