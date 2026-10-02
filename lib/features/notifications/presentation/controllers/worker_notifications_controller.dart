import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/worker_notification_entity.dart';
import '../../domain/repository/worker_notifications_repository.dart';
import '../providers/notifications_providers.dart';
import 'worker_notifications_state.dart';

class WorkerNotificationsController
    extends Notifier<WorkerNotificationsState> {
  late final WorkerNotificationsRepository _repository;

  StreamSubscription<void>? _subscription;

  @override
  WorkerNotificationsState build() {
    _repository = ref.read(
      workerNotificationsRepositoryProvider,
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const WorkerNotificationsState();
  }

  Future<void> initialize() async {
    await load();

    await _subscription?.cancel();

    _subscription = _repository
        .watchNotifications()
        .listen((_) {
      load(silent: true);
    });
  }

  Future<void> load({
    bool silent = false,
  }) async {
    if (!silent) {
      state = state.copyWith(
        status: WorkerNotificationsStatus.loading,
        clearError: true,
      );
    }

    try {
      final notifications =
          await _repository.getNotifications();

      state = state.copyWith(
        status: WorkerNotificationsStatus.success,
        notifications: List.unmodifiable(
          notifications,
        ),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: WorkerNotificationsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> markAsRead(
    String notificationId,
  ) async {
    final index = state.notifications.indexWhere(
      (item) => item.id == notificationId,
    );

    if (index == -1) {
      return;
    }

    final notification =
        state.notifications[index];

    if (notification.isRead) {
      return;
    }

    try {
      await _repository.markAsRead(
        notificationId,
      );

      final updated =
          List<WorkerNotificationEntity>.from(
        state.notifications,
      );

      updated[index] = WorkerNotificationEntity(
        id: notification.id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        data: notification.data,
        createdAt: notification.createdAt,
        readAt: DateTime.now(),
      );

      state = state.copyWith(
        notifications: List.unmodifiable(updated),
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0 ||
        state.isMarkingAllRead) {
      return;
    }

    state = state.copyWith(
      isMarkingAllRead: true,
    );

    try {
      await _repository.markAllAsRead();

      final now = DateTime.now();

      final updated =
          state.notifications.map((item) {
        if (item.isRead) {
          return item;
        }

        return WorkerNotificationEntity(
          id: item.id,
          type: item.type,
          title: item.title,
          message: item.message,
          data: item.data,
          createdAt: item.createdAt,
          readAt: now,
        );
      }).toList(growable: false);

      state = state.copyWith(
        notifications:
            List.unmodifiable(updated),
        isMarkingAllRead: false,
      );
    } catch (error) {
      state = state.copyWith(
        isMarkingAllRead: false,
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }
}