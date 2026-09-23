import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/workers/presentation/controllers/employer_workers_state.dart';

import 'employer_workers_page.dart';

class EmployerInviteWorkersPage extends StatelessWidget {
  const EmployerInviteWorkersPage({
    super.key,
    required this.jobId,
    this.category,
    this.skill,
  });

  final String jobId;
  final String? category;
  final String? skill;

  @override
  Widget build(BuildContext context) {
    return EmployerWorkersPage(
      jobId: jobId,
      category: category,
      skill: skill,
      initialTab: EmployerWorkersTab.workers,
    );
  }
}