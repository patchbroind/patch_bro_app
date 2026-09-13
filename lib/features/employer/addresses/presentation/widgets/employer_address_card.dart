import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_tappable_card.dart';

import '../../domain/entities/employer_address_entity.dart';

class EmployerAddressCard extends StatelessWidget {
  const EmployerAddressCard({super.key, required this.address, required this.onMenuTap});

  final EmployerAddressEntity address;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AppTappableCard(
        onTap: null,
        color: AppColors.transparent,
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.employerLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.employerPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved address',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.formattedAddress,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              tooltip: 'Address actions',
              onPressed: onMenuTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 21),
            ),
          ],
        ),
      ),
    );
  }
}
