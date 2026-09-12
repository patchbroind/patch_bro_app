import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerJobImage extends StatelessWidget {
  const EmployerJobImage({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return const _Placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return const _Placeholder(showProgress: true);
        },
        errorBuilder: (context, error, stackTrace) {
          return const _Placeholder();
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: showProgress
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.image_outlined, size: 28, color: AppColors.imagePlaceholderIcon),
    );
  }
}
