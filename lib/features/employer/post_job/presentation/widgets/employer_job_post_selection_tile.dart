import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class SelectionTile
    extends StatelessWidget {
  const SelectionTile({super.key, 
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final isSelected =
        !value.startsWith(
      'Select',
    );

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    AppColors.employerLight,
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.employerPrimary,
                size: 20,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    value,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}