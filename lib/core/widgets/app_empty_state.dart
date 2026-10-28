import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

/// A consistent no-content message that can be used in full-page and compact
/// section contexts.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.layout = AppEmptyStateLayout.centered,
    this.padding = EdgeInsets.zero,
    this.iconSize,
    this.iconColor = AppColors.textDisabled,
    this.titleColor = AppColors.textPrimary,
    this.messageColor = AppColors.textSecondary,
    this.iconToContentSpacing = 14,
    this.titleToMessageSpacing = 6,
  }) : assert(layout == AppEmptyStateLayout.inline || title != null);

  /// The compact layout is intended for a status row inside another card.
  /// The centered layout is intended for a list or page with no content.
  final AppEmptyStateLayout layout;
  final String? title;
  final String message;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final double? iconSize;
  final Color? iconColor;
  final Color? titleColor;
  final Color? messageColor;
  final double iconToContentSpacing;
  final double titleToMessageSpacing;

  @override
  Widget build(BuildContext context) {
    if (layout == AppEmptyStateLayout.inline) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon!, size: iconSize, color: iconColor),
              SizedBox(width: iconToContentSpacing),
            ],
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: messageColor),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: iconSize, color: iconColor),
            SizedBox(height: iconToContentSpacing),
          ],
          Text(
            title!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: titleToMessageSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: messageColor),
          ),
        ],
      ),
    );
  }
}

enum AppEmptyStateLayout { centered, inline }
