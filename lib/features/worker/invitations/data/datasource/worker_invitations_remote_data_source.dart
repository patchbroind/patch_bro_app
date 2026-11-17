import 'dart:async';

import 'package:patch_bro/core/network/api_client.dart';
import 'package:patch_bro/core/network/api_endpoinds.dart';
import 'package:patch_bro/features/worker/invitations/domain/entities/worker_invitation_media.dart';
import 'package:patch_bro/shared/invitations/data/model/job_invitation_model.dart';
import 'package:patch_bro/shared/invitations/domain/entities/realtime_sync_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerInvitationsRemoteDataSource {
  WorkerInvitationsRemoteDataSource(this._supabase, this._apiClient);

  final SupabaseClient _supabase;
  final ApiClient _apiClient;

  Future<List<JobInvitationModel>> getInvitations() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    final response = await _supabase.rpc('get_worker_invitations');

    if (response is! List) {
      throw const PostgrestException(message: 'Invalid invitations response.');
    }

    return response
        .map(
          (item) => JobInvitationModel.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<void> acceptInvitation(String invitationId) async {
    await _supabase.rpc(
      'accept_job_invitation',
      params: {'p_invitation_id': invitationId},
    );
  }

  Future<void> rejectInvitation(String invitationId) async {
    await _supabase.rpc(
      'reject_job_invitation',
      params: {'p_invitation_id': invitationId},
    );
  }

  Stream<RealtimeSyncEvent> watchInvitations({required String workerProfileId}) {
    final controller = StreamController<RealtimeSyncEvent>.broadcast();

    if (workerProfileId.trim().isEmpty) {
      controller.add(const RealtimeSyncEvent.error('Worker profile ID is missing.'));
      controller.close();
      return controller.stream;
    }

    final channel = _supabase.channel('worker-job-invitations-$workerProfileId-${DateTime.now().microsecondsSinceEpoch}');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'job_invitations',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'worker_id',
        value: workerProfileId,
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
        final message = error?.toString() ?? status.name;
        controller.add(RealtimeSyncEvent.error(
          message,
          isRecoverable: !_isFilterConfigurationError(message),
        ));
      } else if (status == RealtimeSubscribeStatus.closed) {
        controller.add(const RealtimeSyncEvent.disconnected());
      }
    });

    controller.onCancel = () async {
      await _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  bool _isFilterConfigurationError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('invalid column for filter') ||
        normalized.contains('p0001') ||
        normalized.contains('worker_id');
  }


  Future<WorkerInvitationMedia> getInvitationMedia(
    String invitationId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.workerInvitationMedia(invitationId),
    );

    final responseData = response.data;

    if (responseData is! Map) {
      throw Exception('Invalid invitation media response.');
    }

    final data = responseData['data'];

    if (data is! Map) {
      throw Exception('Invitation media not found.');
    }

    return WorkerInvitationMedia.fromMap(
      Map<String, dynamic>.from(data),
    );
  }
}

