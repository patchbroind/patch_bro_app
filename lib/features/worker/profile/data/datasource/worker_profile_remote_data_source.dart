import 'package:patch_bro/features/worker/profile/data/models/worker_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerProfileRemoteDataSource {
  WorkerProfileRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ============================================================
  // GET CURRENT WORKER PROFILE
  // ============================================================

  Future<WorkerProfileModel?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    final response = await _supabase
        .from('worker_profiles')
        .select(
          '''
          id,
          profession,
          skills,
          about,
          experience_years,
          availability_days,
          available_today,
          available_tomorrow,
          avatar_url
          ''',
        )
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return WorkerProfileModel.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  // ============================================================
  // SAVE WORKER PROFILE
  // ============================================================

  Future<void> saveProfile({
    required String profession,
    required List<String> skills,
    required String about,
    required int experienceYears,
    required List<String> availabilityDays,
    required bool availableToday,
    required bool availableTomorrow,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'No authenticated user found.',
      );
    }

    await _supabase
        .from('worker_profiles')
        .upsert(
      {
        'id': user.id,
        'profession': profession.trim(),
        'skills': skills,
        'about': about.trim(),
        'experience_years': experienceYears,
        'availability_days': availabilityDays,
        'available_today': availableToday,
        'available_tomorrow': availableTomorrow,
      },
      onConflict: 'id',
    );
  }
}