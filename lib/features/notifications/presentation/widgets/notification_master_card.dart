import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/repository/notifications_repository.dart';
import 'notification_setting_row.dart';

class NotificationMasterCard extends StatelessWidget {
  const NotificationMasterCard({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isUpdating,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: NotificationSettingRow(
        icon: Icons.notifications_none_rounded,
        iconColor: AppColors.employerPrimary,
        title: 'Push Notifications',
        description: 'Receive updates about your jobs, messages and more.',
        value: value,
        setting: NotificationSetting.pushNotifications,
        onChanged: onChanged,
        isUpdating: isUpdating,
      ),
    );
  }
}
