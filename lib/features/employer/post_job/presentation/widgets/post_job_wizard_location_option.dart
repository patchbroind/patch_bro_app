import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class PostJobWizardLocationOption extends StatelessWidget {
  const PostJobWizardLocationOption({super.key, 
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? AppColors.employerPrimary : AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.employerPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_circle, color: AppColors.employerPrimary),
        ],
      ),
    ),
  );
}