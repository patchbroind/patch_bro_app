
import 'package:flutter/foundation.dart';

@immutable
class WorkerHomeJobEntity {
  const WorkerHomeJobEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.locationAddress,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    this.scheduledSlotIds = const [],
    this.latitude,
    this.longitude,
    this.description = '',
    this.imageUrl,
    this.imageUrls = const [],
    this.audioUrl,
    this.audioStoragePath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String category;
  final String locationAddress;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String status;

  final List<String> scheduledSlotIds;

  final double? latitude;
  final double? longitude;

  final String description;

  final String? imageUrl;
  final List<String> imageUrls;

  final String? audioUrl;
  final String? audioStoragePath;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasLocation =>
      latitude != null && longitude != null;

  bool get hasDescription =>
      description.trim().isNotEmpty;

  bool get hasVoiceNote =>
      audioUrl != null && audioUrl!.trim().isNotEmpty;

  bool get hasImages =>
      imageUrls.isNotEmpty ||
      (imageUrl != null && imageUrl!.trim().isNotEmpty);

  List<String> get effectiveImageUrls {
    if (imageUrls.isNotEmpty) {
      return List.unmodifiable(imageUrls);
    }

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return [imageUrl!];
    }

    return const [];
  }

  bool get isCompleted =>
      status.trim().toLowerCase() == 'completed';

  bool get isUpcomingOrActive {
    final normalized = status.trim().toLowerCase();

    return !const {
      'completed',
      'cancelled',
      'canceled',
      'expired',
    }.contains(normalized);
  }

  WorkerHomeJobEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? locationAddress,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? status,
    List<String>? scheduledSlotIds,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    String? audioUrl,
    String? audioStoragePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkerHomeJobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      locationAddress: locationAddress ?? this.locationAddress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      scheduledSlotIds: scheduledSlotIds ?? this.scheduledSlotIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      audioStoragePath: audioStoragePath ?? this.audioStoragePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}