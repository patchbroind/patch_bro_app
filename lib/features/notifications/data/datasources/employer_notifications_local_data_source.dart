import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/employer_notification_preferences.dart';
import '../../domain/repository/employer_notifications_repository.dart';

class EmployerNotificationsLocalDataSource {
  EmployerNotificationsLocalDataSource(this._supabase);

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

  Future<EmployerNotificationPreferences> getPreferences() async {
    final preferences = await _preferences();
    final prefix = _prefix;

    return EmployerNotificationPreferences(
      pushNotifications: preferences.getBool('${prefix}push') ?? true,
      jobUpdates: preferences.getBool('${prefix}jobs') ?? true,
      messages: preferences.getBool('${prefix}messages') ?? true,
      reminders: preferences.getBool('${prefix}reminders') ?? true,
      offersAndPromotions: preferences.getBool('${prefix}offers') ?? false,
      appAnnouncements: preferences.getBool('${prefix}announcements') ?? true,
    );
  }

  Future<void> setPreference(EmployerNotificationSetting setting, bool enabled) async {
    final preferences = await _preferences();
    final prefix = _prefix;
    final key = switch (setting) {
      EmployerNotificationSetting.pushNotifications => '${prefix}push',
      EmployerNotificationSetting.jobUpdates => '${prefix}jobs',
      EmployerNotificationSetting.messages => '${prefix}messages',
      EmployerNotificationSetting.reminders => '${prefix}reminders',
      EmployerNotificationSetting.offersAndPromotions => '${prefix}offers',
      EmployerNotificationSetting.appAnnouncements => '${prefix}announcements',
    };

    if (!await preferences.setBool(key, enabled)) {
      throw StateError('Unable to save notification preference.');
    }
  }
}
