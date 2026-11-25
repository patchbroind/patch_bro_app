import 'package:material_ui/material_ui.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerJobDetailsInformationRow extends StatelessWidget {
  const WorkerJobDetailsInformationRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: WorkerColors.textSecondary),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WorkerColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}