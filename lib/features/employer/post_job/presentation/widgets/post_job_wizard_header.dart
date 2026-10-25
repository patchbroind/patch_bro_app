import 'package:flutter/material.dart';

class PostJobWizardHeader extends StatelessWidget {
  const PostJobWizardHeader({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / 6;
    final labels = ['Category', 'Schedule', 'Location', 'Description', 'Images', 'Workers'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${step + 1} of 6 · ${labels[step]}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, minHeight: 7),
          ),
        ],
      ),
    );
  }
}