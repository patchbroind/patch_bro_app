import 'package:flutter/foundation.dart';

import '../../domain/entities/worker_notification_entity.dart';

enum WorkerNotificationsStatus {
  initial,
  loading,
  success,
  failure,
}

@immutable
class WorkerNotificationsState {
  const WorkerNotificationsState({
    this.status = WorkerNotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.isMarkingAllRead = false,
  });

  final WorkerNotificationsStatus status;
  final List<WorkerNotificationEntity> notifications;
  final String? errorMessage;
  final bool isMarkingAllRead;

  bool get isLoading =>
      status == WorkerNotificationsStatus.loading;

  bool get isFailure =>
      status == WorkerNotificationsStatus.failure;

  int get unreadCount =>
      notifications.where((item) => !item.isRead).length;

  bool get hasNotifications => notifications.isNotEmpty;

  WorkerNotificationsState copyWith({
    WorkerNotificationsStatus? status,
    List<WorkerNotificationEntity>? notifications,
    String? errorMessage,
    bool? isMarkingAllRead,
    bool clearError = false,
  }) {
    return WorkerNotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      isMarkingAllRead:
          isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }
}