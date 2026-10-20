import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

class PostJobWorkerCard extends StatelessWidget {
  const PostJobWorkerCard({
    super.key,
    required this.worker,
    required this.isSelected,
    this.canSelect = true,
    required this.onToggleSelected,
    required this.onMoreDetails,
  });

  final EmployerWorkerEntity worker;
  final bool isSelected;
  final bool canSelect;
  final VoidCallback onToggleSelected;
  final VoidCallback onMoreDetails;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.employerPrimary : AppColors.border;
    final location = worker.location.trim();
    final skills = worker.skills
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .take(6)
        .toList(growable: false);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canSelect ? onToggleSelected : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            boxShadow: const [
              BoxShadow(color: Color(0x19001B17), blurRadius: 22, offset: Offset(0, 10)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatarWidget(size: 72, name: worker.name, imageUrl: worker.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name.trim().isEmpty ? 'Worker' : worker.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        worker.profession,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Semantics(
                  label: !canSelect
                      ? 'Worker is not eligible for this job'
                      : isSelected
                      ? 'Deselect worker'
                      : 'Select worker',
                  checked: isSelected,
                  child: Checkbox(
                    key: ValueKey('post-job-worker-selection-${worker.id}'),
                    value: isSelected,
                    onChanged: canSelect ? (_) => onToggleSelected() : null,
                    activeColor: AppColors.employerPrimary,
                    checkColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    side: const BorderSide(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.location_on_outlined,
              text: location.isEmpty ? 'Location unavailable' : location,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (skills.isEmpty)
                      Text(
                        'No skills listed',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      )
                    else
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: skills
                            .map(
                              (skill) => Container(
                                constraints: const BoxConstraints(maxWidth: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.employerLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  skill,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.employerDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            icon: Icons.payments_outlined,
                            label: 'Minimum wage',
                            value: 'Not provided',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Metric(
                            icon: Icons.star_rounded,
                            label: 'Rating',
                            value: worker.rating > 0
                                ? '${worker.rating.toStringAsFixed(1)}'
                                      '${worker.reviewCount > 0 ? ' (${worker.reviewCount})' : ''}'
                                : 'No ratings yet',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onMoreDetails,
                icon: const Icon(Icons.open_in_new_rounded, size: 17),
                label: const Text('More Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.employerPrimary,
                  side: const BorderSide(color: AppColors.employerPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 15, color: AppColors.employerPrimary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      const SizedBox(height: 3),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: AppColors.employerPrimary),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}
