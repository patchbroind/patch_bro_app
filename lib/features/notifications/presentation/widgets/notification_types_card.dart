import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_notification_preferences.dart';
import '../../domain/repository/employer_notifications_repository.dart';
import 'notification_setting_row.dart';

class NotificationTypesCard extends StatelessWidget {
  const NotificationTypesCard({
    super.key,
    required this.preferences,
    required this.updatingSetting,
    required this.onChanged,
  });

  final EmployerNotificationPreferences preferences;
  final EmployerNotificationSetting? updatingSetting;
  final void Function(EmployerNotificationSetting setting, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        setting: EmployerNotificationSetting.jobUpdates,
        icon: Icons.work_outline_rounded,
        color: AppColors.info,
        title: 'Job Updates',
        description: 'Stay informed about your jobs and activity.',
        value: preferences.jobUpdates,
      ),
      (
        setting: EmployerNotificationSetting.messages,
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.success,
        title: 'Messages',
        description: 'Get notified when workers message you.',
        value: preferences.messages,
      ),
      (
        setting: EmployerNotificationSetting.reminders,
        icon: Icons.notifications_none_rounded,
        color: AppColors.warning,
        title: 'Reminders',
        description: 'Receive reminders about important actions.',
        value: preferences.reminders,
      ),
      (
        setting: EmployerNotificationSetting.offersAndPromotions,
        icon: Icons.local_offer_outlined,
        color: AppColors.error,
        title: 'Offers & Promotions',
        description: 'Hear about offers and useful promotions.',
        value: preferences.offersAndPromotions,
      ),
      (
        setting: EmployerNotificationSetting.appAnnouncements,
        icon: Icons.campaign_outlined,
        color: AppColors.employerSecondary,
        title: 'App Announcements',
        description: 'Learn about important Patch Bro updates.',
        value: preferences.appAnnouncements,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            NotificationSettingRow(
              setting: rows[index].setting,
              icon: rows[index].icon,
              iconColor: rows[index].color,
              title: rows[index].title,
              description: rows[index].description,
              value: rows[index].value,
              isUpdating: updatingSetting == rows[index].setting,
              onChanged: (value) => onChanged(rows[index].setting, value),
            ),
            if (index < rows.length - 1) const Divider(height: 1, indent: 68, endIndent: 14),
          ],
        ],
      ),
    );
  }
}
