import '../entities/employer_profile_entity.dart';

abstract interface class EmployerProfileRepository {
  Future<EmployerProfileEntity> getEmployerProfile();
}