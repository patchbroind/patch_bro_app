import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({
    super.key,
    this.label = 'OR',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(
          alpha: 0.18,
        );

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: color,
          ),
        ),
      ],
    );
  }
}