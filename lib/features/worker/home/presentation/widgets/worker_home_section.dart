import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerHomeSection extends StatelessWidget {
  const WorkerHomeSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.onViewAll,
    this.iconBackgroundColor,
    this.iconColor,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 12),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.contentSpacing = 14,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final void Function()? onViewAll;

  final Color? iconBackgroundColor;
  final Color? iconColor;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double contentSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: WorkerColors.cardShadow, blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? WorkerColors.homePrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor ?? WorkerColors.homePrimary, size: 23),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: WorkerColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All', style: TextStyle(color: WorkerColors.homePrimary)),
              ),
            ],
          ),
          SizedBox(height: contentSpacing),
          child,
        ],
      ),
    );
  }
}
