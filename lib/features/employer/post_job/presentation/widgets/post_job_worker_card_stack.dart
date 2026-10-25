import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';

import 'post_job_worker_card.dart';

class PostJobWorkerCardStack extends StatefulWidget {
  const PostJobWorkerCardStack({
    super.key,
    required this.workers,
    required this.activeIndex,
    required this.selectedWorkerIds,
    required this.eligibleWorkerIds,
    required this.allowIneligibleSelection,
    required this.onIndexChanged,
    required this.onToggleSelected,
    required this.onMoreDetails,
    required this.height,
  });

  final List<EmployerWorkerEntity> workers;
  final int activeIndex;
  final Set<String> selectedWorkerIds;
  final Set<String> eligibleWorkerIds;
  final bool allowIneligibleSelection;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<String> onToggleSelected;
  final ValueChanged<EmployerWorkerEntity> onMoreDetails;
  final double height;

  @override
  State<PostJobWorkerCardStack> createState() => _PostJobWorkerCardStackState();
}

class _PostJobWorkerCardStackState extends State<PostJobWorkerCardStack> {
  double _dragDistance = 0;
  int _slideDirection = 1;

  void _moveBy(int amount) {
    final next = widget.activeIndex + amount;
    if (next < 0 || next >= widget.workers.length) return;
    _slideDirection = amount;
    widget.onIndexChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workers.isEmpty) return const SizedBox.shrink();

    final index = widget.activeIndex.clamp(0, widget.workers.length - 1).toInt();
    final activeWorker = widget.workers[index];
    final previousWorker = index > 0 ? widget.workers[index - 1] : null;
    final nextWorker = index < widget.workers.length - 1 ? widget.workers[index + 1] : null;
    final cardHeight = widget.height - 42;

    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) => _dragDistance += details.delta.dx,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (_dragDistance < -35 || velocity < -250) {
                  _moveBy(1);
                } else if (_dragDistance > 35 || velocity > 250) {
                  _moveBy(-1);
                }
                _dragDistance = 0;
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (nextWorker != null)
                    Positioned(
                      left: 12,
                      right: -10,
                      top: 9,
                      bottom: 0,
                      child: _CardPreview(
                        worker: nextWorker,
                        height: cardHeight,
                        selected: widget.selectedWorkerIds.contains(nextWorker.id),
                        canSelect:
                            widget.allowIneligibleSelection ||
                            widget.eligibleWorkerIds.contains(nextWorker.id),
                      ),
                    ),
                  if (previousWorker != null)
                    Positioned(
                      left: -10,
                      right: 12,
                      top: 9,
                      bottom: 0,
                      child: _CardPreview(
                        worker: previousWorker,
                        height: cardHeight,
                        selected: widget.selectedWorkerIds.contains(previousWorker.id),
                        canSelect:
                            widget.allowIneligibleSelection ||
                            widget.eligibleWorkerIds.contains(previousWorker.id),
                      ),
                    ),
                  Positioned(
                    left: 22,
                    right: 22,
                    top: 0,
                    bottom: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: Offset(_slideDirection * 0.16, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: SizedBox(
                        key: ValueKey(activeWorker.id),
                        height: cardHeight,
                        child: PostJobWorkerCard(
                          key: ValueKey('active-${activeWorker.id}'),
                          worker: activeWorker,
                          isSelected: widget.selectedWorkerIds.contains(activeWorker.id),
                          canSelect:
                              widget.allowIneligibleSelection ||
                              widget.eligibleWorkerIds.contains(activeWorker.id),
                          onToggleSelected: () => widget.onToggleSelected(activeWorker.id),
                          onMoreDetails: () => widget.onMoreDetails(activeWorker),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: index > 0 ? () => _moveBy(-1) : null,
                  tooltip: 'Previous worker',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  '${index + 1} of ${widget.workers.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: index < widget.workers.length - 1 ? () => _moveBy(1) : null,
                  tooltip: 'Next worker',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.worker,
    required this.height,
    required this.selected,
    required this.canSelect,
  });

  final EmployerWorkerEntity worker;
  final double height;
  final bool selected;
  final bool canSelect;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Opacity(
      opacity: 0.88,
      child: SizedBox(
        height: height,
        child: PostJobWorkerCard(
          worker: worker,
          isSelected: selected,
          canSelect: canSelect,
          onToggleSelected: () {},
          onMoreDetails: () {},
        ),
      ),
    ),
  );
}
