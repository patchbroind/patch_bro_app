import '../entities/employer_trust_entity.dart';

abstract interface class EmployerTrustRepository {
  Future<EmployerTrustEntity> getTrustDetails();
}
