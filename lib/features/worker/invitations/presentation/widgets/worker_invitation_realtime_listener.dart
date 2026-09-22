import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../providers/worker_invitations_providers.dart';
import 'worker_job_invitation_dialog.dart';

class WorkerInvitationRealtimeListener
    extends ConsumerStatefulWidget {
  const WorkerInvitationRealtimeListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<
      WorkerInvitationRealtimeListener>
  createState() =>
      _WorkerInvitationRealtimeListenerState();
}

class _WorkerInvitationRealtimeListenerState
    extends ConsumerState<
        WorkerInvitationRealtimeListener> {
  StreamSubscription<void>?
      _subscription;

  final Set<String>
      _knownInvitationIds = {};

  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  Future<void> _initialize() async {
    final repository =
        ref.read(
      workerInvitationsRepositoryProvider,
    );

    try {
      final initial =
          await repository
              .getInvitations();

      for (final invitation
          in initial) {
        _knownInvitationIds
            .add(invitation.id);
      }

      // Show currently active invitations
      // when the worker enters the app.
      final active =
          initial
              .where(
                (item) => item.isActive,
              )
              .toList();

      if (active.isNotEmpty) {
        await _showInvitations(
          active,
        );
      }

      _subscription =
          repository
              .watchInvitations()
              .listen((_) async {
        if (!mounted) {
          return;
        }

        try {
          final invitations =
              await repository
                  .getInvitations();

          final newInvitations =
              invitations
                  .where(
                    (item) =>
                        !_knownInvitationIds
                            .contains(
                          item.id,
                        ) &&
                        item.isActive,
                  )
                  .toList();

          for (final invitation
              in invitations) {
            _knownInvitationIds
                .add(invitation.id);
          }

          if (newInvitations
              .isNotEmpty) {
            await _showInvitations(
              newInvitations,
            );
          }
        } catch (_) {
          // The worker invitation page/
          // controller will retry separately.
        }
      });
    } catch (_) {
      // The normal worker invitation
      // controller handles errors.
    }
  }

  Future<void> _showInvitations(
    List<JobInvitationEntity>
        invitations,
  ) async {
    if (_showingDialog ||
        !mounted) {
      return;
    }

    _showingDialog = true;

    try {
      for (final invitation
          in invitations) {
        if (!mounted) {
          break;
        }

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return WorkerJobInvitationDialog(
              invitation:
                  invitation,
            );
          },
        );
      }
    } finally {
      _showingDialog = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return widget.child;
  }
}