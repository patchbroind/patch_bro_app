import 'package:flutter/foundation.dart';

@immutable
class EmployerNotificationPreferences {
  const EmployerNotificationPreferences({
    this.pushNotifications = true,
    this.jobUpdates = true,
    this.messages = true,
    this.reminders = true,
    this.offersAndPromotions = false,
    this.appAnnouncements = true,
  });

  final bool pushNotifications;
  final bool jobUpdates;
  final bool messages;
  final bool reminders;
  final bool offersAndPromotions;
  final bool appAnnouncements;

  EmployerNotificationPreferences copyWith({
    bool? pushNotifications,
    bool? jobUpdates,
    bool? messages,
    bool? reminders,
    bool? offersAndPromotions,
    bool? appAnnouncements,
  }) {
    return EmployerNotificationPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      jobUpdates: jobUpdates ?? this.jobUpdates,
      messages: messages ?? this.messages,
      reminders: reminders ?? this.reminders,
      offersAndPromotions: offersAndPromotions ?? this.offersAndPromotions,
      appAnnouncements: appAnnouncements ?? this.appAnnouncements,
    );
  }
}
