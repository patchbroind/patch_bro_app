import 'package:patch_bro/features/worker/profile/domain/entities/worker_profile_entity.dart';

class WorkerProfileModel extends WorkerProfileEntity {
  const WorkerProfileModel({
    required super.id,
    required super.profession,
    required super.skills,
    required super.about,
    required super.experienceYears,
    required super.availabilityDays,
    required super.availableToday,
    required super.availableTomorrow,
    super.availabilitySchedule,
    super.avatarUrl,
  });

  factory WorkerProfileModel.fromMap(Map<String, dynamic> map) {
    return WorkerProfileModel(
      id: map['id']?.toString() ?? '',
      profession: map['profession']?.toString() ?? 'Other',
      skills: _stringList(map['skills']),
      about: map['about']?.toString() ?? '',
      experienceYears: _intValue(map['experience_years']),
      availabilityDays: _stringList(map['availability_days']),
      availableToday: map['available_today'] == true,
      availableTomorrow: map['available_tomorrow'] == true,
      availabilitySchedule: _scheduleMap(map['availability_schedule']),
      avatarUrl: _nullableString(map['avatar_url']),
    );
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

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }

  static Map<String, Map<String, String>> _scheduleMap(dynamic value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.value is Map)
          entry.key.toString(): {
            for (final slot in (entry.value as Map).entries)
              slot.key.toString(): slot.value.toString(),
          },
    };
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    return valueString.isEmpty ? null : valueString;
  }
}
