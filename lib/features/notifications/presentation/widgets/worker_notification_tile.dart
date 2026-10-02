import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/worker_notification_entity.dart';

class WorkerNotificationTile extends StatelessWidget {
  const WorkerNotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final WorkerNotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    final backgroundColor =
        notification.isRead
            ? Theme.of(context).cardColor
            : primaryColor.withValues(alpha: 0.06);

    final iconData = _icon;

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight:
                                      notification.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                                const EdgeInsets.only(
                              top: 5,
                              left: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatDate(
                        notification.createdAt,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (notification.type) {
      case 'job_invitation':
        return Icons.work_outline_rounded;

      case 'job_cancelled':
        return Icons.cancel_outlined;

      case 'message':
        return Icons.chat_bubble_outline_rounded;

      case 'payment':
        return Icons.account_balance_wallet_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day'
          '${difference.inDays == 1 ? '' : 's'} ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}