import 'package:flutter/material.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_primary_outlined_button.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';

class JobDetailActionButtons extends StatelessWidget {
  const JobDetailActionButtons({super.key, 
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppPrimaryOutlinedButton(label: 'Edit Job', icon: const Icon(Icons.edit_outlined), onPressed: () {
            
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppPrimaryButton(label:'Invite Workers' , 
          leadingIcon: Icon(
              Icons.people_outline,
            ),
            labelStyle: const TextStyle(fontSize: 14),
          onPressed: () {
            
          },)
          
        ),
      ],
    );
  }
}