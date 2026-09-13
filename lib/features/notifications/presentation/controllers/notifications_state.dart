import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_preferences.dart';
import '../../domain/repository/notifications_repository.dart';

enum NotificationsStatus { initial, loading, success, failure }

@immutable
class NotificationsState {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.preferences,
    this.errorMessage,
    this.updatingSetting,
  });

  final NotificationsStatus status;
  final NotificationPreferences? preferences;
  final String? errorMessage;
  final NotificationSetting? updatingSetting;

  bool get isLoading => status == NotificationsStatus.loading;
  bool get isFailure => status == NotificationsStatus.failure;
  bool get hasPreferences => preferences != null;

  NotificationsState copyWith({
    NotificationsStatus? status,
    NotificationPreferences? preferences,
    String? errorMessage,
    NotificationSetting? updatingSetting,
    bool clearError = false,
    bool clearUpdatingSetting = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      updatingSetting: clearUpdatingSetting ? null : updatingSetting ?? this.updatingSetting,
    );
  }
}
