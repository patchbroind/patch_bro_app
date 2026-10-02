import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/notifications/data/datasources/worker_notifications_remote_data_source.dart';

import '../../data/datasources/notifications_local_data_source.dart';
import '../../data/repository/notifications_repository_impl.dart';
import '../../data/repository/worker_notifications_repository_impl.dart';
import '../../domain/repository/notifications_repository.dart';
import '../../domain/repository/worker_notifications_repository.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/notifications_state.dart';
import '../controllers/worker_notifications_controller.dart';
import '../controllers/worker_notifications_state.dart';

final notificationsDataSourceProvider =
    Provider<NotificationsLocalDataSource>((ref) {
  return NotificationsLocalDataSource(
    ref.read(supabaseClientProvider),
  );
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    ref.read(notificationsDataSourceProvider),
  );
});

final notificationsControllerProvider =
    NotifierProvider<
      NotificationsController,
      NotificationsState
    >(
      NotificationsController.new,
    );


// ============================================================
// WORKER NOTIFICATIONS
// ============================================================

final workerNotificationsRemoteDataSourceProvider =
    Provider<WorkerNotificationsRemoteDataSource>(
  (ref) {
    return WorkerNotificationsRemoteDataSource(
      ref.read(supabaseClientProvider),
    );
  },
);

final workerNotificationsRepositoryProvider =
    Provider<WorkerNotificationsRepository>(
  (ref) {
    return WorkerNotificationsRepositoryImpl(
      ref.read(
        workerNotificationsRemoteDataSourceProvider,
      ),
    );
  },
);

final workerNotificationsControllerProvider =
    NotifierProvider<
      WorkerNotificationsController,
      WorkerNotificationsState
    >(
      WorkerNotificationsController.new,
    );