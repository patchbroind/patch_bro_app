import '../../domain/entities/worker_notification_entity.dart';
import '../../domain/repository/worker_notifications_repository.dart';
import '../datasources/worker_notifications_remote_data_source.dart';

class WorkerNotificationsRepositoryImpl
    implements WorkerNotificationsRepository {
  WorkerNotificationsRepositoryImpl(
    this._dataSource,
  );

  final WorkerNotificationsRemoteDataSource _dataSource;

  @override
  Future<List<WorkerNotificationEntity>> getNotifications() async {
    final models = await _dataSource.getNotifications();

    return models
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead(
    String notificationId,
  ) {
    return _dataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }

  @override
  Stream<void> watchNotifications() {
    return _dataSource.watchNotifications();
  }
}