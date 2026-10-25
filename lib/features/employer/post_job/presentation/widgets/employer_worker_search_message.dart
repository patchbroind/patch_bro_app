import 'package:flutter/material.dart';

class EmptyWorkerSearchMessage extends StatelessWidget {
  const EmptyWorkerSearchMessage({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(message, textAlign: TextAlign.center),
    ],
  );
}