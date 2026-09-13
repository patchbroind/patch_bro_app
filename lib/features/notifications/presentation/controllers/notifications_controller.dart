import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_preferences.dart';
import '../../domain/repository/notifications_repository.dart';
import '../providers/employer_notifications_providers.dart';
import 'notifications_state.dart';

class NotificationsController extends Notifier<NotificationsState> {
  NotificationsRepository get _repository {
    return ref.read(employerNotificationsRepositoryProvider);
  }

  @override
  NotificationsState build() {
    return const NotificationsState();
  }

  Future<void> loadNotificationPreferences() async {
    if (state.isLoading) return;

    state = state.copyWith(status: NotificationsStatus.loading, clearError: true);
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(
        status: NotificationsStatus.success,
        preferences: preferences,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshNotificationPreferences() async {
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(
        status: NotificationsStatus.success,
        preferences: preferences,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: state.hasPreferences
            ? NotificationsStatus.success
            : NotificationsStatus.failure,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> updatePreference(NotificationSetting setting, bool enabled) async {
    final current = state.preferences;
    if (current == null || state.updatingSetting != null) return;

    final updated = _copyPreference(current, setting, enabled);
    state = state.copyWith(preferences: updated, updatingSetting: setting, clearError: true);

    try {
      await _repository.setPreference(setting, enabled);
      state = state.copyWith(clearUpdatingSetting: true);
    } catch (error) {
      state = state.copyWith(
        preferences: current,
        errorMessage: error.toString(),
        clearUpdatingSetting: true,
      );
      rethrow;
    }
  }

  NotificationPreferences _copyPreference(
    NotificationPreferences current,
    NotificationSetting setting,
    bool enabled,
  ) {
    return switch (setting) {
      NotificationSetting.pushNotifications => current.copyWith(pushNotifications: enabled),
      NotificationSetting.jobUpdates => current.copyWith(jobUpdates: enabled),
      NotificationSetting.messages => current.copyWith(messages: enabled),
      NotificationSetting.reminders => current.copyWith(reminders: enabled),
      NotificationSetting.offersAndPromotions => current.copyWith(
        offersAndPromotions: enabled,
      ),
      NotificationSetting.appAnnouncements => current.copyWith(appAnnouncements: enabled),
    };
  }
}
