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
    super.verified,
  });

  factory EmployerWorkerModel.fromMap(Map<String, dynamic> map) {
    return EmployerWorkerModel(
      id: _stringValue(map['id']),
      name: _stringValue(map['name']),
      profession: _stringValue(map['profession'], fallback: 'Other'),
      rating: _doubleValue(map['rating']),
      reviewCount: _intValue(map['review_count']),
      distanceKm: _doubleValue(map['distance_km']),
      isFavourite: _boolValue(map['is_favourite']),
      isAvailableToday: _boolValue(map['is_available_today']),
      availableTomorrow: _boolValue(map['available_tomorrow']),
      skills: _stringList(map['skills']),
      avatarUrl: _nullableString(map['avatar_url']),
      about: _stringValue(map['about']),
      experienceYears: _intValue(map['experience_years']),
      jobsCompleted: _intValue(map['jobs_completed']),
      responseRate: _intValue(map['response_rate']),
      availabilityDays: _stringList(map['availability_days']),
      location: _stringValue(map['location']),
      phone: _stringValue(map['phone']),
      verified: _boolValue(map['verified']),
    );
  }

  factory EmployerWorkerModel.fromEntity(EmployerWorkerEntity entity) {
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
      verified: entity.verified,
    );
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    return value.toString();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _doubleValue(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }

    return const [];
  }
}
