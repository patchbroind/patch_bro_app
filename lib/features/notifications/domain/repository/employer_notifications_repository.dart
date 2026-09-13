import '../entities/employer_notification_preferences.dart';

enum EmployerNotificationSetting {
  pushNotifications,
  jobUpdates,
  messages,
  reminders,
  offersAndPromotions,
  appAnnouncements,
}

abstract interface class EmployerNotificationsRepository {
  Future<EmployerNotificationPreferences> getPreferences();

  Future<void> setPreference(EmployerNotificationSetting setting, bool enabled);
}
