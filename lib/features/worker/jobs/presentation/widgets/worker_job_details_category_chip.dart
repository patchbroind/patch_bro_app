import 'package:material_ui/material_ui.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class WorkerJobDetailsCategoryChip extends StatelessWidget {
  const WorkerJobDetailsCategoryChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: WorkerColors.homePrimaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: WorkerColors.homePrimary),

          const SizedBox(width: 6),

          Text(
            label.isEmpty ? 'Not specified' : label,
            style: const TextStyle(
              color: WorkerColors.homePrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}