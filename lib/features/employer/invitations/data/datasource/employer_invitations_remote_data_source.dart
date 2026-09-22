import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../shared/invitations/data/model/job_invitation_model.dart';

class EmployerInvitationsRemoteDataSource {
  EmployerInvitationsRemoteDataSource(
    this._supabase,
  );

  final SupabaseClient _supabase;

  Future<JobInvitationModel> inviteWorker({
    required String jobId,
    required String workerId,
  }) async {
    final response =
        await _supabase.rpc(
      'create_job_invitation',
      params: {
        'p_job_id': jobId,
        'p_worker_id': workerId,
      },
    );

    if (response == null) {
      throw const PostgrestException(
        message:
            'Invalid invitation response.',
      );
    }

    if (response is Map) {
      return JobInvitationModel.fromMap(
        Map<String, dynamic>.from(response),
      );
    }

    if (response is List &&
        response.isNotEmpty) {
      return JobInvitationModel.fromMap(
        Map<String, dynamic>.from(
          response.first as Map,
        ),
      );
    }

    throw const PostgrestException(
      message:
          'Invalid invitation response.',
    );
  }

  Future<List<JobInvitationModel>>
      getJobInvitations(
    String jobId,
  ) async {
    final response =
        await _supabase.rpc(
      'get_employer_job_invitations',
      params: {
        'p_job_id': jobId,
      },
    );

    if (response is! List) {
      throw const PostgrestException(
        message:
            'Invalid invitations response.',
      );
    }

    return response
        .map(
          (item) =>
              JobInvitationModel.fromMap(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList(growable: false);
  }

  Stream<void> watchJobInvitations(
    String jobId,
  ) {
    final controller =
        StreamController<void>.broadcast();

    final channel = _supabase.channel(
      'employer-job-invitations-$jobId',
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'job_invitations',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'job_id',
        value: jobId,
      ),
      callback: (_) {
        if (!controller.isClosed) {
          controller.add(null);
        }
      },
    );

    channel.subscribe();

    controller.onCancel = () async {
      await _supabase.removeChannel(
        channel,
      );
    };

    return controller.stream;
  }
}