import 'package:flutter/material.dart';

class AppPrimaryOutlinedButton extends StatelessWidget {
  const AppPrimaryOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
  });

  final String label;
  final Widget? icon;
  final void Function()? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color ?? Theme.of(context).colorScheme.primary;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: foregroundColor),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
