import 'package:flutter/foundation.dart';

@immutable
class WorkerProfileEntity {
  const WorkerProfileEntity({
    required this.id,
    required this.profession,
    required this.skills,
    required this.about,
    required this.experienceYears,
    required this.availabilityDays,
    required this.availableToday,
    required this.availableTomorrow,
    this.avatarUrl,
  });

  final String id;
  final String profession;
  final List<String> skills;
  final String about;
  final int experienceYears;
  final List<String> availabilityDays;
  final bool availableToday;
  final bool availableTomorrow;
  final String? avatarUrl;

  WorkerProfileEntity copyWith({
    String? id,
    String? profession,
    List<String>? skills,
    String? about,
    int? experienceYears,
    List<String>? availabilityDays,
    bool? availableToday,
    bool? availableTomorrow,
    String? avatarUrl,
  }) {
    return WorkerProfileEntity(
      id: id ?? this.id,
      profession: profession ?? this.profession,
      skills: skills ?? this.skills,
      about: about ?? this.about,
      experienceYears:
          experienceYears ?? this.experienceYears,
      availabilityDays:
          availabilityDays ?? this.availabilityDays,
      availableToday:
          availableToday ?? this.availableToday,
      availableTomorrow:
          availableTomorrow ?? this.availableTomorrow,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}