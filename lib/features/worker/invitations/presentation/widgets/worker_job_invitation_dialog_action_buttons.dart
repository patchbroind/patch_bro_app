import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_primary_outlined_button.dart';
import 'package:patch_bro/features/worker/invitations/presentation/providers/worker_invitations_providers.dart';

class WorkerJobInvitationDialogActionButtons extends StatelessWidget {
  const WorkerJobInvitationDialogActionButtons({super.key, required this.ref, required this.invitationID,required this.isResponding});
  final WidgetRef ref;
  final String invitationID;
  final bool isResponding;

  @override
  Widget build(BuildContext context) {
    return Row(
            children: [
              Expanded(
                child: AppPrimaryOutlinedButton(
                  label: 'Reject',
                  onPressed: () async {
                    try {
                      await ref
                          .read(workerInvitationsControllerProvider.notifier)
                          .reject(invitationID);

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).pop();
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      AppSnackbar.error(context, error.toString().replaceFirst('Exception: ', ''));
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppPrimaryButton(
                  label: 'Accept',
                  backgroundColor: AppColors.workerPrimary,
                  isLoading: isResponding,
                  onPressed: () async {
                    try {
                      await ref
                          .read(workerInvitationsControllerProvider.notifier)
                          .accept(invitationID);

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).pop();
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      AppSnackbar.error(context, error.toString().replaceFirst('Exception: ', ''));
                    }
                  },
                ),
              ),
            ],
          );
  }
}