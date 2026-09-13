import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class PostJobRemoteDataSource {
  final SupabaseClient _client;

  PostJobRemoteDataSource(this._client);

  Future<void> createJob({
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
    File? voiceRecording,
    required List<File> images,
  }) async {
    /*
     * IMPORTANT:
     *
     * The current Patch Bro database migrations do not yet define
     * the jobs table/storage contract.
     *
     * Do not add a guessed:
     *
     *   supabase.from('jobs').insert(...)
     *
     * here.
     *
     * Once the actual jobs schema is available, this method becomes
     * the ONLY backend boundary that needs to be changed.
     */

    throw UnimplementedError(
      'Post Job backend contract is not available yet.',
    );
  }
}