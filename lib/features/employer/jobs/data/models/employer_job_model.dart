import '../../domain/entities/employer_job_entity.dart';

class EmployerJobModel {
  const EmployerJobModel({
    required this.id,
    required this.category,
    required this.skill,
    required this.date,
    required this.time,
    required this.locationAddress,
    required this.description,
    required this.status,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.audioUrl,
  });

  final String id;
  final String category;
  final String skill;
  final DateTime date;
  final DateTime time;
  final String locationAddress;
  final String description;
  final EmployerJobStatus status;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? audioUrl;

  factory EmployerJobModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmployerJobModel(
      id: json['id'].toString(),
      category:
          json['category']?.toString() ?? '',
      skill:
          json['skill']?.toString() ?? '',
      date: _parseDate(
        json['scheduled_date'],
      ),
      time: _parseTime(
        json['scheduled_time'],
      ),
      locationAddress:
          json['location_address']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      status: _parseStatus(
        json['status'],
      ),
      latitude: _toDouble(
        json['latitude'],
      ),
      longitude: _toDouble(
        json['longitude'],
      ),
      imageUrl:
          _toNullableString(
        json['image_url'],
      ),
      audioUrl: _toNullableString(
        json['audio_url'],
),
    );
  }

  EmployerJobEntity toEntity() {
    return EmployerJobEntity(
      id: id,
      category: category,
      skill: skill,
      date: date,
      time: time,
      locationAddress: locationAddress,
      description: description,
      status: status,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
    );
  }

  static DateTime _parseDate(
    dynamic value,
  ) {
    final parsed = DateTime.tryParse(
      value?.toString() ?? '',
    );

    if (parsed == null) {
      throw const FormatException(
        'Invalid job scheduled date.',
      );
    }

    return parsed;
  }

  static DateTime _parseTime(
    dynamic value,
  ) {
    final stringValue =
        value?.toString() ?? '';

    final parts =
        stringValue.split(':');

    final hour =
        int.tryParse(
              parts.isNotEmpty
                  ? parts[0]
                  : '',
            ) ??
            0;

    final minute =
        int.tryParse(
              parts.length > 1
                  ? parts[1]
                  : '',
            ) ??
            0;

    final second =
        int.tryParse(
              parts.length > 2
                  ? parts[2]
                  : '',
            ) ??
            0;

    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
    );
  }

  static EmployerJobStatus _parseStatus(
    dynamic value,
  ) {
    switch (
        value
            ?.toString()
            .trim()
            .toLowerCase()) {
      case 'open':
      case 'pending':
      case 'assigned':
      case 'accepted':
      case 'in_progress':
      case 'in-progress':
        return EmployerJobStatus.active;

      case 'completed':
        return EmployerJobStatus.completed;

      case 'cancelled':
      case 'canceled':
        return EmployerJobStatus.cancelled;

      default:
        return EmployerJobStatus.active;
    }
  }

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static String? _toNullableString(
    dynamic value,
  ) {
    final result =
        value?.toString().trim();

    if (result == null ||
        result.isEmpty) {
      return null;
    }

    return result;
  }
}