import 'package:flutter/foundation.dart';

@immutable
class WorkerNotificationEntity {
  const WorkerNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  bool get isJobInvitation => type == 'job_invitation';

  bool get isJobCancelled => type == 'job_cancelled';
}