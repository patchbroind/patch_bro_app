import '../entities/employer_benefit_entity.dart';

abstract interface class EmployerBenefitRepository {
  Future<EmployerBenefitEntity> getBenefitDetails();
}
