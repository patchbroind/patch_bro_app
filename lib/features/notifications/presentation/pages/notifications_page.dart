import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import '../../domain/repository/notifications_repository.dart';
import '../controllers/notifications_state.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_master_card.dart';
import '../widgets/notification_types_card.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notificationsControllerProvider.notifier).loadNotificationPreferences();
      }
    });
  }

  Future<void> _refresh() async {
    try {
      await ref
          .read(notificationsControllerProvider.notifier)
          .refreshNotificationPreferences();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Unable to refresh notification settings.');
      }
    }
  }

  void _retry() {
    ref.read(notificationsControllerProvider.notifier).loadNotificationPreferences();
  }

  Future<void> _updateSetting(NotificationSetting setting, bool value) async {
    try {
      await ref
          .read(notificationsControllerProvider.notifier)
          .updatePreference(setting, value);
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Unable to save notification setting.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading && !state.hasPreferences) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasPreferences) {
      return AppErrorView(
        title: 'Unable to load Notifications',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    final preferences = state.preferences;
    if (preferences == null) {
      return AppErrorView(
        title: 'Unable to load Notifications',
        message: 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 32),
            children: [
              NotificationMasterCard(
                value: preferences.pushNotifications,
                isUpdating: state.updatingSetting == NotificationSetting.pushNotifications,
                onChanged: (value) =>
                    _updateSetting(NotificationSetting.pushNotifications, value),
              ),
              const SizedBox(height: 24),
              Text(
                'Notification Types',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              NotificationTypesCard(
                preferences: preferences,
                updatingSetting: state.updatingSetting,
                onChanged: _updateSetting,
              ),
            ],
          );
        },
      ),
    );
  }
}
