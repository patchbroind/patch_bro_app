import '../entities/notification_preferences.dart';

enum NotificationSetting {
  pushNotifications,
  jobUpdates,
  messages,
  reminders,
  offersAndPromotions,
  appAnnouncements,
}

abstract interface class NotificationsRepository {
  Future<NotificationPreferences> getPreferences();

  Future<void> setPreference(NotificationSetting setting, bool enabled);
}
