import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../providers/worker_invitations_providers.dart';
import 'worker_job_invitation_dialog.dart';

class WorkerInvitationRealtimeListener extends ConsumerStatefulWidget {
  const WorkerInvitationRealtimeListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WorkerInvitationRealtimeListener> createState() =>
      _WorkerInvitationRealtimeListenerState();
}

class _WorkerInvitationRealtimeListenerState
    extends ConsumerState<WorkerInvitationRealtimeListener> {
  final Set<String> _knownInvitationIds = {};
  final List<JobInvitationEntity> _pendingDialogs = [];
  bool _showingDialog = false;
  bool _hasObservedInitialState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(workerInvitationsControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(workerInvitationsControllerProvider, (previous, next) {
      final invitations = next.invitations;
      if (!_hasObservedInitialState) {
        _hasObservedInitialState = true;
        _knownInvitationIds.addAll(invitations.map((item) => item.id));
        return;
      }

      for (final invitation in invitations) {
        final isNew = _knownInvitationIds.add(invitation.id);
        if (isNew && invitation.isActive) _pendingDialogs.add(invitation);
      }
      if (_pendingDialogs.isNotEmpty) _showPendingDialogs();
    });
    return widget.child;
  }

  Future<void> _showPendingDialogs() async {
    if (_showingDialog || !mounted) return;
    _showingDialog = true;
    try {
      while (_pendingDialogs.isNotEmpty && mounted) {
        final invitation = _pendingDialogs.removeAt(0);
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => WorkerJobInvitationDialog(invitation: invitation),
        );
      }
    } finally {
      _showingDialog = false;
    }
  }
}
