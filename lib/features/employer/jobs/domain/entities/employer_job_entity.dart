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
    required this.createdAt,
    required this.updatedAt,
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
  final DateTime createdAt;
  final DateTime updatedAt;

  final double? latitude;
  final double? longitude;

  final String? imageUrl;
  final String? audioUrl;

  // ============================================================
  // COMPUTED PROPERTIES
  // ============================================================

  String get title => skill;

  bool get hasDescription =>
      description.trim().isNotEmpty;

  bool get hasVoiceDescription =>
      audioUrl != null &&
      audioUrl!.trim().isNotEmpty;

  bool get hasImage =>
      imageUrl != null &&
      imageUrl!.trim().isNotEmpty;

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

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