import 'package:flutter/foundation.dart';

@immutable
class EmployerWorkerEntity {
  const EmployerWorkerEntity({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isFavourite,
    required this.isAvailableToday,
    required this.availableTomorrow,
    required this.skills,
    this.avatarUrl,
    this.about = '',
    this.experienceYears = 0,
    this.jobsCompleted = 0,
    this.responseRate = 0,
    this.availabilityDays = const [],
    this.location = '',
    this.phone = '',
    this.verified = false,
  });

  final String id;
  final String name;
  final String profession;

  final double rating;
  final int reviewCount;
  final double distanceKm;

  final bool isFavourite;
  final bool isAvailableToday;
  final bool availableTomorrow;

  final List<String> skills;

  final String? avatarUrl;

  final String about;
  final int experienceYears;
  final int jobsCompleted;
  final int responseRate;

  final List<String> availabilityDays;

  final String location;
  final String phone;

  final bool verified;

  EmployerWorkerEntity copyWith({
    String? id,
    String? name,
    String? profession,
    double? rating,
    int? reviewCount,
    double? distanceKm,
    bool? isFavourite,
    bool? isAvailableToday,
    bool? availableTomorrow,
    List<String>? skills,
    String? avatarUrl,
    String? about,
    int? experienceYears,
    int? jobsCompleted,
    int? responseRate,
    List<String>? availabilityDays,
    String? location,
    String? phone,
    bool? verified,
  }) {
    return EmployerWorkerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
      isFavourite: isFavourite ?? this.isFavourite,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      availableTomorrow: availableTomorrow ?? this.availableTomorrow,
      skills: skills ?? this.skills,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      about: about ?? this.about,
      experienceYears: experienceYears ?? this.experienceYears,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      responseRate: responseRate ?? this.responseRate,
      availabilityDays: availabilityDays ?? this.availabilityDays,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      verified: verified ?? this.verified,
    );
  }
}
