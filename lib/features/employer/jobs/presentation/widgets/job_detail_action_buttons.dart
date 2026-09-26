import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_primary_outlined_button.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';

class JobDetailActionButtons extends StatelessWidget {
  const JobDetailActionButtons({super.key, required this.job, this.onJobEdited});

  final EmployerJobEntity job;
  final VoidCallback? onJobEdited;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppPrimaryOutlinedButton(
            label: 'Edit Job',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await context.pushNamed<bool>(RouteNames.employerEditJob, extra: job);

              if (result == true) {
                onJobEdited?.call();
              }
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: AppPrimaryButton(
            label: 'Invite Workers',
            leadingIcon: const Icon(Icons.people_outline),
            labelStyle: const TextStyle(fontSize: 14),
            onPressed: () {
              context.pushNamed(
                RouteNames.employerInviteWorkers,
                queryParameters: {'jobId': job.id, 'category': job.category, 'skill': job.skill},
              );
            },
          ),
        ),
      ],
    );
  }
}
