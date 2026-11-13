import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/router/route_names.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, required this.unreadCount, required this.config});

  final int unreadCount;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.pushNamed(config.isWorker
          ? RouteNames.workerNotifications
          : RouteNames.employerNotifications),
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
