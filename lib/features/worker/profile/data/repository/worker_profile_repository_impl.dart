import 'package:patch_bro/features/worker/profile/data/datasource/worker_profile_remote_data_source.dart';
import 'package:patch_bro/features/worker/profile/domain/entities/worker_profile_entity.dart';
import 'package:patch_bro/features/worker/profile/domain/repository/worker_profile_repository.dart';

class WorkerProfileRepositoryImpl
    implements WorkerProfileRepository {
  WorkerProfileRepositoryImpl(
    this._remoteDataSource,
  );

  final WorkerProfileRemoteDataSource _remoteDataSource;

  @override
  Future<WorkerProfileEntity?> getCurrentProfile() {
    return _remoteDataSource.getCurrentProfile();
  }

  @override
  Future<void> saveProfile({
    required String profession,
    required List<String> skills,
    required String about,
    required int experienceYears,
    required List<String> availabilityDays,
    required bool availableToday,
    required bool availableTomorrow,
  }) {
    return _remoteDataSource.saveProfile(
      profession: profession,
      skills: skills,
      about: about,
      experienceYears: experienceYears,
      availabilityDays: availabilityDays,
      availableToday: availableToday,
      availableTomorrow: availableTomorrow,
    );
  }
}