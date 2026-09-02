import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasource/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>(
  (ref) {
    return ProfileRemoteDataSource(
      ref.read(supabaseClientProvider),
    );
  },
);

final profileRepositoryProvider =
    Provider<ProfileRepository>(
  (ref) {
    return ProfileRepositoryImpl(
      ref.read(profileRemoteDataSourceProvider),
    );
  },
);