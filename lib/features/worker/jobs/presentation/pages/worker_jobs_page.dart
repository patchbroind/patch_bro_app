import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class WorkerJobsPage extends ConsumerWidget {
  const WorkerJobsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 12),
            Center(
              child: Icon(Icons.work_history_outlined, size: 56, color: AppColors.employerPrimary),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No jobs assigned yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Your upcoming jobs will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
