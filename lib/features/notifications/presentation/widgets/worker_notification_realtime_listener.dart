import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/features/notifications/data/datasources/worker_notifications_remote_data_source.dart';
import 'package:patch_bro/features/notifications/presentation/providers/notifications_providers.dart';

class WorkerNotificationRealtimeListener
    extends ConsumerStatefulWidget {
  const WorkerNotificationRealtimeListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<
      WorkerNotificationRealtimeListener>
  createState() =>
      _WorkerNotificationRealtimeListenerState();
}

class _WorkerNotificationRealtimeListenerState
    extends ConsumerState<
        WorkerNotificationRealtimeListener> {
  StreamSubscription<void>?
      _subscription;

  final Set<String>
      _knownNotificationIds = {};

  bool _showingDialog = false;

  WorkerNotificationsRemoteDataSource
      get _dataSource {
    return ref.read(
      workerNotificationsRemoteDataSourceProvider,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  Future<void> _initialize() async {
    try {
      final initial =
          await _dataSource.getNotifications();

      for (final notification
          in initial) {
        _knownNotificationIds
            .add(notification.id);
      }

      _subscription = _dataSource
          .watchNotifications()
          .listen(
        (_) async {
          if (!mounted) {
            return;
          }

          try {
            final notifications =
                await _dataSource
                    .getNotifications();

            final newNotifications =
                notifications
                    .where(
                      (notification) =>
                          !_knownNotificationIds
                              .contains(
                            notification.id,
                          ),
                    )
                    .toList(
                      growable: false,
                    );

            for (final notification
                in notifications) {
              _knownNotificationIds
                  .add(notification.id);
            }

            for (final notification
                in newNotifications) {
              if (notification.type ==
                  'job_cancelled') {
                await _showCancellation(
                  notification,
                );
              }
            }
          } catch (_) {
            // Ignore realtime failures.
          }
        },
      );
    } catch (_) {
      // Ignore initial notification failures.
    }
  }

  Future<void> _showCancellation(
    WorkerNotificationModel notification,
  ) async {
    if (_showingDialog ||
        !mounted) {
      return;
    }

    _showingDialog = true;

    try {
      await AppDialog.alert(
        context,
        title: notification.title,
        message: notification.message,
        buttonLabel: 'OK',
        icon: Icons.cancel_outlined,
      );
    } finally {
      _showingDialog = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return widget.child;
  }
}