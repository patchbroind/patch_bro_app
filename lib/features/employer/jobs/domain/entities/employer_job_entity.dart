import 'package:flutter/foundation.dart';

enum EmployerJobStatus { active, completed, cancelled }

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
    this.imageUrls = const [],
    this.imagePaths = const [],
    this.audioUrl,
    this.audioPath,
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

  /// First image, kept for backward compatibility.
  final String? imageUrl;

  /// All existing signed image URLs.
  final List<String> imageUrls;

  /// Storage paths corresponding to [imageUrls].
  ///
  /// These are used only when editing a job so the backend knows
  /// which existing images should remain.
  final List<String> imagePaths;

  final String? audioUrl;

  /// Storage path of the existing audio file.
  final String? audioPath;

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  String get title => skill;

  bool get hasDescription => description.trim().isNotEmpty;

  bool get hasVoiceDescription => audioUrl != null && audioUrl!.trim().isNotEmpty;

  bool get hasImage => imageUrls.isNotEmpty || (imageUrl != null && imageUrl!.trim().isNotEmpty);

  bool get hasLocation => latitude != null && longitude != null;

  List<String> get effectiveImageUrls {
    if (imageUrls.isNotEmpty) {
      return List.unmodifiable(imageUrls);
    }

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return [imageUrl!];
    }

    return const [];
  }

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
