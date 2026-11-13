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
    final userId = _userId;
    var response = await _supabase
        .from('notification_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) {
      // Import this account's prior local values once; absent keys retain defaults.
      final local = await _legacyPreferences();
      response = await _supabase.from('notification_preferences').upsert({
        'user_id': userId,
        'push_notifications': local.pushNotifications,
        'job_updates': local.jobUpdates,
        'messages': local.messages,
        'reminders': local.reminders,
        'offers_and_promotions': local.offersAndPromotions,
        'app_announcements': local.appAnnouncements,
      }, onConflict: 'user_id').select().single();
    }
    return _fromMap(response);
  }

  Future<void> setPreference(NotificationSetting setting, bool enabled) async {
    final column = switch (setting) {
      NotificationSetting.pushNotifications => 'push_notifications',
      NotificationSetting.jobUpdates => 'job_updates',
      NotificationSetting.messages => 'messages',
      NotificationSetting.reminders => 'reminders',
      NotificationSetting.offersAndPromotions => 'offers_and_promotions',
      NotificationSetting.appAnnouncements => 'app_announcements',
    };
    await _supabase.from('notification_preferences').upsert({
      'user_id': _userId,
      column: enabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  String get _userId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('No authenticated user found.');
    return user.id;
  }

  Future<NotificationPreferences> _legacyPreferences() async {
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

  NotificationPreferences _fromMap(Map<String, dynamic> map) => NotificationPreferences(
    pushNotifications: map['push_notifications'] as bool? ?? true,
    jobUpdates: map['job_updates'] as bool? ?? true,
    messages: map['messages'] as bool? ?? true,
    reminders: map['reminders'] as bool? ?? true,
    offersAndPromotions: map['offers_and_promotions'] as bool? ?? false,
    appAnnouncements: map['app_announcements'] as bool? ?? true,
  );
}
