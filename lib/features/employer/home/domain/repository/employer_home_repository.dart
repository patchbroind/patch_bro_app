import '../entities/employer_home_entity.dart';

abstract interface class EmployerHomeRepository {
  Future<EmployerHomeEntity> getHomeData();

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  });
}
