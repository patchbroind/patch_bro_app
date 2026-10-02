import '../entities/worker_notification_entity.dart';

abstract interface class WorkerNotificationsRepository {
  Future<List<WorkerNotificationEntity>> getNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Stream<void> watchNotifications();
}