import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/verified_badge.dart';

class EmployerPersonalInfoRow extends StatelessWidget {
  const EmployerPersonalInfoRow({super.key, 
    required this.icon,
    required this.label,
    required this.value,
    this.verified = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.trim().isNotEmpty == true ? value!.trim() : 'Not available';

    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, color: AppColors.employerPrimary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      displayValue,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (verified) const VerifiedBadge(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


