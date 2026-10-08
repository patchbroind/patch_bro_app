import 'package:patch_bro/features/employer/home/data/model/employer_home_model.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';
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
      return const EmployerHomeModel(name: 'User');
    }

    return EmployerHomeModel.fromMap(data, avatarUrl: data['avatar_url']?.toString());
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    await _remoteDataSource.updateLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return _remoteDataSource.getCategories();
  }
}
