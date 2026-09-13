import '../../domain/entities/employer_notification_preferences.dart';
import '../../domain/repository/employer_notifications_repository.dart';
import '../datasources/employer_notifications_local_data_source.dart';

class EmployerNotificationsRepositoryImpl implements EmployerNotificationsRepository {
  EmployerNotificationsRepositoryImpl(this._dataSource);

  final EmployerNotificationsLocalDataSource _dataSource;

  @override
  Future<EmployerNotificationPreferences> getPreferences() {
    return _dataSource.getPreferences();
  }

  @override
  Future<void> setPreference(EmployerNotificationSetting setting, bool enabled) {
    return _dataSource.setPreference(setting, enabled);
  }
}
