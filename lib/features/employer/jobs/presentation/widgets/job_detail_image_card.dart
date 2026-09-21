import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_section_card.dart';

class JobDetailImagesCard extends StatelessWidget {
  const JobDetailImagesCard({super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return JobDetailSectionCard(
      title: 'Job Image',
      icon: Icons.image_outlined,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder:
                (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress ==
                  null) {
                return child;
              }

              return const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.employerPrimary,
                ),
              );
            },
            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return const _ImageError();
            },
          ),
        ),
      ),
    );
  }
}

class _ImageError
    extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          AppColors.imagePlaceholder,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color:
              AppColors.imagePlaceholderIcon,
        ),
      ),
    );
  }
}