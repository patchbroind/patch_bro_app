import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_primary_outlined_button.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/jobs/presentation/providers/employer_jobs_providers.dart';

class JobDetailActionButtons extends ConsumerStatefulWidget {
  const JobDetailActionButtons({
    super.key,
    required this.job,
    this.onJobEdited,
    this.onJobCancelled,
  });

  final EmployerJobEntity job;

  final VoidCallback? onJobEdited;

  final VoidCallback? onJobCancelled;

  @override
  ConsumerState<JobDetailActionButtons> createState() => _JobDetailActionButtonsState();
}

class _JobDetailActionButtonsState extends ConsumerState<JobDetailActionButtons> {
  bool _isCancelling = false;

  Future<void> _cancelJob() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Cancel Job?',
      message: 'Are you sure you want to cancel this job? The assigned worker will be notified.',
      confirmLabel: 'Cancel Job',
      cancelLabel: 'Keep Job',
      icon: Icons.cancel_outlined,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await ref.read(employerJobsControllerProvider.notifier).cancelJob(widget.job.id);

      if (!mounted) {
        return;
      }

      AppSnackbar.success(context, 'Job cancelled successfully.');

      widget.onJobCancelled?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, _cleanErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.job.status == EmployerJobStatus.completed ||
        widget.job.status == EmployerJobStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppPrimaryOutlinedButton(
                label: 'Edit Job',
                icon: const Icon(Icons.edit_outlined),
                onPressed: _isCancelling
                    ? null
                    : () async {
                        final result = await context.pushNamed<bool>(
                          RouteNames.employerEditJob,
                          extra: widget.job,
                        );

                        if (result == true) {
                          widget.onJobEdited?.call();
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
                onPressed: _isCancelling
                    ? null
                    : () {
                        context.pushNamed(
                          RouteNames.employerInviteWorkers,
                          queryParameters: {
                            'jobId': widget.job.id,
                            'category': widget.job.category,
                            'skill': widget.job.skill,
                          },
                        );
                      },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isCancelling ? null : _cancelJob,
            icon: _isCancelling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                  )
                : const Icon(Icons.cancel_outlined),
            label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Job'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
