
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/worker/invitations/presentation/providers/worker_invitations_providers.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitation_list.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitations_header.dart';
import 'package:patch_bro/features/worker/invitations/presentation/widgets/worker_invitations_tab_bar.dart';

class WorkerInvitationsPage extends ConsumerStatefulWidget {
  const WorkerInvitationsPage({super.key});

  @override
  ConsumerState<WorkerInvitationsPage> createState() =>
      _WorkerInvitationsPageState();
}

class _WorkerInvitationsPageState
    extends ConsumerState<WorkerInvitationsPage> {
  WorkerInvitationTab _selectedTab = WorkerInvitationTab.active;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(workerInvitationsControllerProvider.notifier).initialize();
    });
  }

  Future<void> _refresh() async {
    await ref.read(workerInvitationsControllerProvider.notifier).load();
  }

  Future<void> _accept(String id) async {
    try {
      await ref.read(workerInvitationsControllerProvider.notifier).accept(id);

      if (!mounted) return;

      AppSnackbar.success(
        context,
        'Invitation accepted successfully.',
      );

      // The accepted invitation no longer belongs in Active.
      setState(() {
        _selectedTab = WorkerInvitationTab.active;
      });
    } catch (error) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _decline(String id) async {
    try {
      await ref.read(workerInvitationsControllerProvider.notifier).reject(id);

      if (!mounted) return;

      AppSnackbar.success(
        context,
        'Invitation declined.',
      );
    } catch (error) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitationState = ref.watch(workerInvitationsControllerProvider);

    final isActive = _selectedTab == WorkerInvitationTab.active;

    final invitations = isActive
        ? invitationState.activeInvitations
        : invitationState.expiredInvitations;

    return Scaffold(
      backgroundColor: WorkerColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            const WorkerInvitationsHeader(),

            WorkerInvitationsTabBar(
              selectedTab: _selectedTab,
              activeCount: invitationState.activeCount,
              expiredCount: invitationState.expiredCount,
              onChanged: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),

            if (invitationState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        invitationState.errorMessage!,
                        style: const TextStyle(
                          color: WorkerColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: RefreshIndicator(
                color: WorkerColors.homePrimary,
                onRefresh: _refresh,
                child: WorkerInvitationList(
                  invitations: invitations,
                  isExpired: !isActive,
                  isLoading: invitationState.isLoading,
                  respondingInvitationId:
                      invitationState.respondingInvitationId,
                  respondingAction: invitationState.respondingAction,
                  onAccept: _accept,
                  onDecline: _decline,
                  onViewDetails: (invitation) {
                    // The existing master branch does not yet have
                    // a dedicated invitation details page or route.
                    // We can add that separately when designed.
                    context.push(
                      '/worker/notifications',
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: WorkerColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Invitations expire after the response deadline.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: WorkerColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}