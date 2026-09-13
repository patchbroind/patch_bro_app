import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/repository/notifications_repository.dart';

class NotificationSettingRow extends StatelessWidget {
  const NotificationSettingRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.value,
    required this.setting,
    required this.onChanged,
    this.isUpdating = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool value;
  final NotificationSetting setting;
  final ValueChanged<bool> onChanged;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconContainer(icon: icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _NotificationSwitch(value: value, onChanged: onChanged, enabled: !isUpdating),
        ],
      ),
    );
  }
}

class _IconContainer extends StatelessWidget {
  const _IconContainer({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 21, color: color),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({required this.value, required this.onChanged, required this.enabled});

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: AppColors.white,
      activeTrackColor: AppColors.employerPrimary,
      inactiveThumbColor: AppColors.white,
      inactiveTrackColor: AppColors.border,
      trackOutlineColor: WidgetStatePropertyAll(
        enabled ? AppColors.border : AppColors.textDisabled,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
