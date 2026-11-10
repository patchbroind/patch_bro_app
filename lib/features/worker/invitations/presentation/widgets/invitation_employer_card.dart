
import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_network_image.dart';

import 'invitation_detail_card.dart';

class InvitationEmployerCard extends StatelessWidget {
  const InvitationEmployerCard({
    super.key,
    required this.employerName,
    this.avatarUrl,
    required this.onViewEmployer,
  });

  final String employerName;
  final String? avatarUrl;
  final VoidCallback onViewEmployer;

  @override
  Widget build(BuildContext context) {
    final name = employerName.trim().isEmpty
        ? 'Employer'
        : employerName;

    return InvitationDetailCard(
      icon: Icons.person_outline_rounded,
      title: 'Employer Details',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: AppNetworkImage(
              imageUrl: avatarUrl,
              width: 54,
              height: 54,
              backgroundColor: WorkerColors.homePrimaryLight,
              fallback: const Icon(
                Icons.person_outline_rounded,
                color: WorkerColors.homePrimary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: WorkerColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Employer',
                  style: TextStyle(
                    color: WorkerColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Explicit finite width prevents the inherited button theme
          // from applying an infinite minimum width inside the Row.
          SizedBox(
            width: 140,
            child: OutlinedButton.icon(
              onPressed: onViewEmployer,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
              ),
              label: const Text(
                'View Employer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: WorkerColors.homePrimary,
                side: const BorderSide(
                  color: WorkerColors.homePrimary,
                ),
                minimumSize: const Size(0, 48),
                maximumSize: const Size(140, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
