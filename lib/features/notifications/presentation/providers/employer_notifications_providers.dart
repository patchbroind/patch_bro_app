import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/employer_notifications_local_data_source.dart';
import '../../data/repository/employer_notifications_repository_impl.dart';
import '../../domain/repository/employer_notifications_repository.dart';
import '../controllers/employer_notifications_controller.dart';
import '../controllers/employer_notifications_state.dart';

final employerNotificationsDataSourceProvider = Provider<EmployerNotificationsLocalDataSource>((
  ref,
) {
  return EmployerNotificationsLocalDataSource(ref.read(supabaseClientProvider));
});

final employerNotificationsRepositoryProvider = Provider<EmployerNotificationsRepository>((ref) {
  return EmployerNotificationsRepositoryImpl(ref.read(employerNotificationsDataSourceProvider));
});

final employerNotificationsControllerProvider =
    NotifierProvider<EmployerNotificationsController, EmployerNotificationsState>(
      EmployerNotificationsController.new,
    );
