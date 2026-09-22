import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:patch_bro/shared/invitations/data/model/job_invitation_model.dart';

class WorkerInvitationsRemoteDataSource {
  WorkerInvitationsRemoteDataSource(
    this._supabase,
  );

  final SupabaseClient _supabase;

  Future<List<JobInvitationModel>>
      getInvitations() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    final response =
        await _supabase.rpc(
      'get_worker_invitations',
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

  Future<void> acceptInvitation(
    String invitationId,
  ) async {
    await _supabase.rpc(
      'accept_job_invitation',
      params: {
        'p_invitation_id':
            invitationId,
      },
    );
  }

  Future<void> rejectInvitation(
    String invitationId,
  ) async {
    await _supabase.rpc(
      'reject_job_invitation',
      params: {
        'p_invitation_id':
            invitationId,
      },
    );
  }

  Stream<void> watchInvitations() {
    final controller =
        StreamController<void>.broadcast();

    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      controller.close();
      return controller.stream;
    }

    final channel = _supabase.channel(
      'worker-job-invitations-${user.id}',
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'job_invitations',
      filter: PostgresChangeFilter(
        type:
            PostgresChangeFilterType.eq,
        column: 'worker_id',
        value: user.id,
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