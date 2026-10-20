import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

enum FailedInvitationAction { notNow, reinvite }

class PostJobInvitationFailureDialog extends StatelessWidget {
  const PostJobInvitationFailureDialog({
    super.key,
    required this.failedWorkerNames,
    required this.totalSelected,
  });

  final List<String> failedWorkerNames;
  final int totalSelected;

  @override
  Widget build(BuildContext context) {
    final failedCount = failedWorkerNames.length;
    final isTotalFailure = failedCount == totalSelected;
    final title = isTotalFailure
        ? 'All $failedCount worker ${failedCount == 1 ? 'invitation failed' : 'invitations failed'}'
        : '$failedCount worker ${failedCount == 1 ? 'invitation failed' : 'invitations failed'}';

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTotalFailure
                      ? 'The job was posted, but none of the selected worker invitations were sent.'
                      : 'The job was posted, but some worker invitations were not sent.',
                ),
                const SizedBox(height: 14),
                Text(
                  'Workers who were not invited:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                ...failedWorkerNames.map(
                  (name) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 7),
                        Expanded(child: Text(name)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(FailedInvitationAction.notNow),
            child: const Text('Not Now'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.employerPrimary),
            onPressed: () => Navigator.of(context).pop(FailedInvitationAction.reinvite),
            child: const Text('Re invite'),
          ),
        ],
      ),
    );
  }
}
