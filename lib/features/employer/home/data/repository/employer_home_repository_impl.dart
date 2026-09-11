import 'package:patch_bro/features/employer/home/data/model/employer_home_model.dart';
import 'package:patch_bro/features/employer/home/domain/repository/employer_home_repository.dart';

import '../../domain/entities/employer_home_entity.dart';
import '../datasources/employer_home_remote_data_source.dart';

class EmployerHomeRepositoryImpl implements EmployerHomeRepository {
  EmployerHomeRepositoryImpl(this._remoteDataSource);

  final EmployerHomeRemoteDataSource _remoteDataSource;

  @override
  Future<EmployerHomeEntity> getHomeData() async {
    final data = await _remoteDataSource.getHomeData();

    if (data == null) {
      return EmployerHomeModel(
        name: 'User',
        avatarUrl: _remoteDataSource.getAvatarUrl(),
      );
    }

    return EmployerHomeModel.fromMap(
      data,
      avatarUrl: _remoteDataSource.getAvatarUrl(),
    );
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return _remoteDataSource.updateLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
