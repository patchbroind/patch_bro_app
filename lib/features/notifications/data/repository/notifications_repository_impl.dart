import '../../domain/entities/notification_preferences.dart';
import '../../domain/repository/notifications_repository.dart';
import '../datasources/notifications_local_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dataSource);

  final NotificationsLocalDataSource _dataSource;

  @override
  Future<NotificationPreferences> getPreferences() {
    return _dataSource.getPreferences();
  }

  @override
  Future<void> setPreference(NotificationSetting setting, bool enabled) {
    return _dataSource.setPreference(setting, enabled);
  }
}
