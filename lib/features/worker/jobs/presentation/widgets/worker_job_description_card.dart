
import 'package:material_ui/material_ui.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';

class WorkerJobDescriptionCard extends StatelessWidget {
  const WorkerJobDescriptionCard({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return WorkerJobDetailSection(
      title: 'Job Description',
      icon: Icons.description_outlined,
      child: SelectableText(
        description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WorkerColors.textSecondary,
              height: 1.6,
            ),
      ),
    );
  }
}