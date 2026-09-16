import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';


class EmployerWorkerModel extends EmployerWorkerEntity {
  const EmployerWorkerModel({
    required super.id,
    required super.name,
    required super.profession,
    required super.rating,
    required super.reviewCount,
    required super.distanceKm,
    required super.isFavourite,
    required super.isAvailableToday,
    required super.availableTomorrow,
    required super.skills,
    super.avatarUrl,
    super.about,
    super.experienceYears,
    super.jobsCompleted,
    super.responseRate,
    super.availabilityDays,
    super.location,
    super.phone,
  });

  factory EmployerWorkerModel.fromEntity(
    EmployerWorkerEntity entity,
  ) {
    return EmployerWorkerModel(
      id: entity.id,
      name: entity.name,
      profession: entity.profession,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      distanceKm: entity.distanceKm,
      isFavourite: entity.isFavourite,
      isAvailableToday: entity.isAvailableToday,
      availableTomorrow: entity.availableTomorrow,
      skills: entity.skills,
      avatarUrl: entity.avatarUrl,
      about: entity.about,
      experienceYears: entity.experienceYears,
      jobsCompleted: entity.jobsCompleted,
      responseRate: entity.responseRate,
      availabilityDays: entity.availabilityDays,
      location: entity.location,
      phone: entity.phone,
    );
  }
}