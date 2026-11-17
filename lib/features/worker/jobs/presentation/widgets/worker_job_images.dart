
import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';

class WorkerJobImages extends StatelessWidget {
  const WorkerJobImages({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return WorkerJobDetailSection(
      title: 'Job Images',
      icon: Icons.photo_library_outlined,
      child: SizedBox(
        height: 190,
        child: PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrls[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return Container(
                      color: WorkerColors.imagePlaceholder,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: WorkerColors.homePrimary,
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) {
                    return Container(
                      color: WorkerColors.imagePlaceholder,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: WorkerColors.textSecondary,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}