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
    this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final String locationAddress;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String status;
  final String? imageUrl;

  bool get isUpcomingOrActive {
    final normalized = status.toLowerCase();
    return !const {'completed', 'cancelled', 'expired'}.contains(normalized);
  }

  bool get isCompleted => status.toLowerCase() == 'completed';

  WorkerHomeJobEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? locationAddress,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? status,
    String? imageUrl,
  }) {
    return WorkerHomeJobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      locationAddress: locationAddress ?? this.locationAddress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
