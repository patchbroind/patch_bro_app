import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';

import '../entities/employer_home_entity.dart';

abstract interface class EmployerHomeRepository {
  Future<EmployerHomeEntity> getHomeData();

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  });

  Future<List<CategoryEntity>> getCategories();
}
