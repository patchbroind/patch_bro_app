import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class PostJobInviteWorkersDialog
    extends StatelessWidget {
  const PostJobInviteWorkersDialog({
    super.key,
    required this.category,
    required this.skill,
    required this.onNotNow,
    required this.onInvite,
  });

  final String category;
  final String skill;
  final VoidCallback onNotNow;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),
      titlePadding:
          const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        0,
      ),
      contentPadding:
          const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        8,
      ),
      actionsPadding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      title: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
                  AppColors.employerLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color:
                  AppColors.employerPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Job Posted Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Would you like to invite workers '
            'for this job now?',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  AppColors.imagePlaceholder,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job',
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skill,
                  style: const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Category',
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onNotNow,
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      AppColors.textPrimary,
                  side: const BorderSide(
                    color:
                        AppColors.border,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child:
                    const Text('Not Now'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onInvite,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.employerPrimary,
                  foregroundColor:
                      AppColors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child:
                    const Text('Invite'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}