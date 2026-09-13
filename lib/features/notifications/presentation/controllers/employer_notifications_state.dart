import 'package:flutter/foundation.dart';

import '../../domain/entities/employer_notification_preferences.dart';
import '../../domain/repository/employer_notifications_repository.dart';

enum EmployerNotificationsStatus { initial, loading, success, failure }

@immutable
class EmployerNotificationsState {
  const EmployerNotificationsState({
    this.status = EmployerNotificationsStatus.initial,
    this.preferences,
    this.errorMessage,
    this.updatingSetting,
  });

  final EmployerNotificationsStatus status;
  final EmployerNotificationPreferences? preferences;
  final String? errorMessage;
  final EmployerNotificationSetting? updatingSetting;

  bool get isLoading => status == EmployerNotificationsStatus.loading;
  bool get isFailure => status == EmployerNotificationsStatus.failure;
  bool get hasPreferences => preferences != null;

  EmployerNotificationsState copyWith({
    EmployerNotificationsStatus? status,
    EmployerNotificationPreferences? preferences,
    String? errorMessage,
    EmployerNotificationSetting? updatingSetting,
    bool clearError = false,
    bool clearUpdatingSetting = false,
  }) {
    return EmployerNotificationsState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      updatingSetting: clearUpdatingSetting ? null : updatingSetting ?? this.updatingSetting,
    );
  }
}
