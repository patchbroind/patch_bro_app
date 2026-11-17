import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patch_bro/shared/invitations/domain/entities/realtime_sync_event.dart';

import '../../../../../shared/invitations/data/model/job_invitation_model.dart';

class EmployerInvitationsRemoteDataSource {
  EmployerInvitationsRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<JobInvitationModel> inviteWorker({required String jobId, required String workerId}) async {
    final response = await _supabase.rpc(
      'create_job_invitation',
      params: {'p_job_id': jobId, 'p_worker_id': workerId},
    );

    if (response == null) {
      throw const PostgrestException(message: 'Invalid invitation response.');
    }

    if (response is Map) {
      return JobInvitationModel.fromMap(Map<String, dynamic>.from(response));
    }

    if (response is List && response.isNotEmpty) {
      return JobInvitationModel.fromMap(Map<String, dynamic>.from(response.first as Map));
    }

    throw const PostgrestException(message: 'Invalid invitation response.');
  }

  Future<List<JobInvitationModel>> getJobInvitations(String jobId) async {
    final response = await _supabase.rpc(
      'get_employer_job_invitations',
      params: {'p_job_id': jobId},
    );

    if (response is! List) {
      throw const PostgrestException(message: 'Invalid invitations response.');
    }

    return response
        .map((item) => JobInvitationModel.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<List<JobInvitationModel>> getWorkerInvitationStatuses(String workerId) async {
    final response = await _supabase.rpc(
      'get_employer_worker_invitation_statuses',
      params: {'p_worker_id': workerId},
    );

    if (response is! List) {
      throw const PostgrestException(message: 'Invalid worker invitation statuses response.');
    }

    return response
        .map((item) => JobInvitationModel.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Stream<RealtimeSyncEvent> watchJobInvitations(String jobId) {
    final controller = StreamController<RealtimeSyncEvent>.broadcast();

    final channel = _supabase.channel('employer-job-invitations-$jobId-${DateTime.now().microsecondsSinceEpoch}');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'job_invitations',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'job_id',
        value: jobId,
      ),
      callback: (payload) {
        if (!controller.isClosed) {
          controller.add(RealtimeSyncEvent.change(payload.eventType));
        }
      },
    );

    channel.subscribe((status, error) {
      if (controller.isClosed) return;
      if (status == RealtimeSubscribeStatus.subscribed) {
        controller.add(const RealtimeSyncEvent.connected());
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        controller.add(RealtimeSyncEvent.error(error?.toString() ?? status.name));
      } else if (status == RealtimeSubscribeStatus.closed) {
        controller.add(const RealtimeSyncEvent.disconnected());
      }
    });

    controller.onCancel = () async {
      await _supabase.removeChannel(channel);
    };

    return controller.stream;
  }
}

