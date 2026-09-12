import '../../domain/entities/employer_benefit_entity.dart';
import '../../domain/repository/employer_benefit_repository.dart';
import '../datasources/employer_benefit_remote_data_source.dart';

class EmployerBenefitRepositoryImpl implements EmployerBenefitRepository {
  EmployerBenefitRepositoryImpl(this._remoteDataSource);

  final EmployerBenefitRemoteDataSource _remoteDataSource;

  @override
  Future<EmployerBenefitEntity> getBenefitDetails() {
    return _remoteDataSource.getBenefitDetails();
  }
}
