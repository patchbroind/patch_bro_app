import 'package:patch_bro/features/employer/profile/data/datasource/employer_profile_remote_data_source.dart';

import '../../domain/entities/employer_profile_entity.dart';
import '../../domain/repository/employer_profile_repository.dart';

class EmployerProfileRepositoryImpl
    implements EmployerProfileRepository {
  EmployerProfileRepositoryImpl(
    this._remoteDataSource,
  );

  final EmployerProfileRemoteDataSource _remoteDataSource;

  @override
  Future<EmployerProfileEntity> getEmployerProfile() {
    return _remoteDataSource.getEmployerProfile();
  }
}