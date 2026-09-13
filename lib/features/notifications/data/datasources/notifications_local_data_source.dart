import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/notification_preferences.dart';
import '../../domain/repository/notifications_repository.dart';

class NotificationsLocalDataSource {
  NotificationsLocalDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<SharedPreferences> _preferences() {
    return SharedPreferences.getInstance();
  }

  String get _prefix {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    return 'employer_notifications_${user.id}_';
  }

  Future<NotificationPreferences> getPreferences() async {
    final preferences = await _preferences();
    final prefix = _prefix;

    return NotificationPreferences(
      pushNotifications: preferences.getBool('${prefix}push') ?? true,
      jobUpdates: preferences.getBool('${prefix}jobs') ?? true,
      messages: preferences.getBool('${prefix}messages') ?? true,
      reminders: preferences.getBool('${prefix}reminders') ?? true,
      offersAndPromotions: preferences.getBool('${prefix}offers') ?? false,
      appAnnouncements: preferences.getBool('${prefix}announcements') ?? true,
    );
  }

  Future<void> setPreference(NotificationSetting setting, bool enabled) async {
    final preferences = await _preferences();
    final prefix = _prefix;
    final key = switch (setting) {
      NotificationSetting.pushNotifications => '${prefix}push',
      NotificationSetting.jobUpdates => '${prefix}jobs',
      NotificationSetting.messages => '${prefix}messages',
      NotificationSetting.reminders => '${prefix}reminders',
      NotificationSetting.offersAndPromotions => '${prefix}offers',
      NotificationSetting.appAnnouncements => '${prefix}announcements',
    };

    if (!await preferences.setBool(key, enabled)) {
      throw StateError('Unable to save notification preference.');
    }
  }
}
