import 'package:flutter/foundation.dart';

enum EmployerJobStatus {
  active,
  completed,
  cancelled,
}

@immutable
class EmployerJobEntity {
  const EmployerJobEntity({
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

  String get title => skill;

  bool get hasVoiceDescription =>
      audioUrl != null && audioUrl!.isNotEmpty;

  bool get hasImages =>
      imageUrl != null && imageUrl!.isNotEmpty;

  String get statusLabel {
    switch (status) {
      case EmployerJobStatus.active:
        return 'Active';

      case EmployerJobStatus.completed:
        return 'Completed';

      case EmployerJobStatus.cancelled:
        return 'Cancelled';
    }
  }
}