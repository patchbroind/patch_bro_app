import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/notifications_local_data_source.dart';
import '../../data/repository/notifications_repository_impl.dart';
import '../../domain/repository/notifications_repository.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/notifications_state.dart';

final notificationsDataSourceProvider = Provider<NotificationsLocalDataSource>((
  ref,
) {
  return NotificationsLocalDataSource(ref.read(supabaseClientProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(ref.read(notificationsDataSourceProvider));
});

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
