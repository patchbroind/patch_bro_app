import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    this.imageWidth,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final double? imageWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                subtitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Image.asset(
          imageAsset,
          width: imageWidth ?? 155,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}