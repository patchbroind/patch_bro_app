import 'package:flutter/material.dart';

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
    this.iconColor,
    this.titleColor,
    this.messageColor,
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
    final colors = Theme.of(context).colorScheme;

    if (layout == AppEmptyStateLayout.inline) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                size: iconSize,
                color: iconColor ?? Theme.of(context).disabledColor,
              ),
              SizedBox(width: iconToContentSpacing),
            ],
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: messageColor ?? colors.onSurfaceVariant,
                ),
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
            Icon(
              icon!,
              size: iconSize,
              color: iconColor ?? Theme.of(context).disabledColor,
            ),
            SizedBox(height: iconToContentSpacing),
          ],
          Text(
            title!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: titleColor ?? colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: titleToMessageSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: messageColor ?? colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

enum AppEmptyStateLayout { centered, inline }
