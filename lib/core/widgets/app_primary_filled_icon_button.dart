
import 'package:flutter/material.dart';

class AppPrimaryFilledIconButton extends StatelessWidget {
  const AppPrimaryFilledIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.labelStyle,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    this.borderRadius = 12,
    this.iconSize = 20,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? labelStyle;

  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor ??
                    Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Icon(icon, size: iconSize),
      label: Text(
        label,
        style: labelStyle,
      ),
    );
  }
}
