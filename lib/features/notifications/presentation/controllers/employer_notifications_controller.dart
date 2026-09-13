import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/employer_notification_preferences.dart';
import '../../domain/repository/employer_notifications_repository.dart';
import '../providers/employer_notifications_providers.dart';
import 'employer_notifications_state.dart';

class EmployerNotificationsController extends Notifier<EmployerNotificationsState> {
  EmployerNotificationsRepository get _repository {
    return ref.read(employerNotificationsRepositoryProvider);
  }

  @override
  EmployerNotificationsState build() {
    return const EmployerNotificationsState();
  }

  Future<void> loadNotificationPreferences() async {
    if (state.isLoading) return;

    state = state.copyWith(status: EmployerNotificationsStatus.loading, clearError: true);
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(
        status: EmployerNotificationsStatus.success,
        preferences: preferences,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: EmployerNotificationsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshNotificationPreferences() async {
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(
        status: EmployerNotificationsStatus.success,
        preferences: preferences,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: state.hasPreferences
            ? EmployerNotificationsStatus.success
            : EmployerNotificationsStatus.failure,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> updatePreference(EmployerNotificationSetting setting, bool enabled) async {
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

  EmployerNotificationPreferences _copyPreference(
    EmployerNotificationPreferences current,
    EmployerNotificationSetting setting,
    bool enabled,
  ) {
    return switch (setting) {
      EmployerNotificationSetting.pushNotifications => current.copyWith(pushNotifications: enabled),
      EmployerNotificationSetting.jobUpdates => current.copyWith(jobUpdates: enabled),
      EmployerNotificationSetting.messages => current.copyWith(messages: enabled),
      EmployerNotificationSetting.reminders => current.copyWith(reminders: enabled),
      EmployerNotificationSetting.offersAndPromotions => current.copyWith(
        offersAndPromotions: enabled,
      ),
      EmployerNotificationSetting.appAnnouncements => current.copyWith(appAnnouncements: enabled),
    };
  }
}
