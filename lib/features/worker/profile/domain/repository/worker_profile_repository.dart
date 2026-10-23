import 'package:patch_bro/features/worker/profile/domain/entities/worker_profile_entity.dart';

abstract interface class WorkerProfileRepository {
  Future<WorkerProfileEntity?> getCurrentProfile();

  Future<void> saveProfile({
    required String profession,
    required List<String> skills,
    required String about,
    required int experienceYears,
    required List<String> availabilityDays,
    required bool availableToday,
    required bool availableTomorrow,
    required Map<String, Map<String, String>> availabilitySchedule,
  });

  Future<void> saveAvailabilitySchedule(
    Map<String, Map<String, String>> schedule,
  );
}
