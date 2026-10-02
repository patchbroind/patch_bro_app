import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import '../../domain/entities/worker_notification_entity.dart';
import '../controllers/worker_notifications_state.dart';
import '../providers/notifications_providers.dart';
import '../widgets/worker_notification_tile.dart';

class WorkerNotificationsPage
    extends ConsumerStatefulWidget {
  const WorkerNotificationsPage({
    super.key,
  });

  @override
  ConsumerState<WorkerNotificationsPage>
      createState() =>
          _WorkerNotificationsPageState();
}

class _WorkerNotificationsPageState
    extends ConsumerState<WorkerNotificationsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          ref
              .read(
                workerNotificationsControllerProvider
                    .notifier,
              )
              .initialize();
        }
      },
    );
  }

  Future<void> _refresh() async {
    await ref
        .read(
          workerNotificationsControllerProvider
              .notifier,
        )
        .load();
  }

  Future<void> _markAllAsRead() async {
    try {
      await ref
          .read(
            workerNotificationsControllerProvider
                .notifier,
          )
          .markAllAsRead();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Unable to mark notifications as read.',
        );
      }
    }
  }

  Future<void> _onNotificationTap(
    WorkerNotificationEntity notification,
  ) async {
    try {
      await ref
          .read(
            workerNotificationsControllerProvider
                .notifier,
          )
          .markAsRead(notification.id);
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Unable to update notification.',
        );
      }
    }

    if (!mounted) {
      return;
    }

    if (notification.isJobInvitation) {
      // The existing realtime invitation listener
      // handles live invitations.
      //
      // We will connect notification navigation
      // to the invitation/job details flow in the
      // next step once the worker job screen is
      // implemented.
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      workerNotificationsControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: state.isMarkingAllRead
                  ? null
                  : _markAllAsRead,
              child: state.isMarkingAllRead
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Read all'),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(
    WorkerNotificationsState state,
  ) {
    if (state.isLoading &&
        !state.hasNotifications) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.workerPrimary,
        ),
      );
    }

    if (state.isFailure &&
        !state.hasNotifications) {
      return AppErrorView(
        title: 'Unable to load notifications',
        message: state.errorMessage ??
            'Please check your connection and try again.',
        icon: Icons.notifications_off_outlined,
        onRetry: () {
          ref
              .read(
                workerNotificationsControllerProvider
                    .notifier,
              )
              .load();
        },
      );
    }

    if (!state.hasNotifications) {
      return RefreshIndicator(
        color: AppColors.workerPrimary,
        onRefresh: _refresh,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.30,
            ),
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.textSecondary
                  .withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No notifications yet',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'New job invitations and updates\n'
                'will appear here.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.workerPrimary,
      onRefresh: _refresh,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: state.notifications.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification =
              state.notifications[index];

          return WorkerNotificationTile(
            notification: notification,
            onTap: () =>
                _onNotificationTap(notification),
          );
        },
      ),
    );
  }
}