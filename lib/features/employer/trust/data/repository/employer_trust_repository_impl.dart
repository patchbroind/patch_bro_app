import '../../domain/entities/employer_trust_entity.dart';
import '../../domain/repository/employer_trust_repository.dart';
import '../datasources/employer_trust_remote_data_source.dart';

class EmployerTrustRepositoryImpl implements EmployerTrustRepository {
  EmployerTrustRepositoryImpl(this._remoteDataSource);

  final EmployerTrustRemoteDataSource _remoteDataSource;

  @override
  Future<EmployerTrustEntity> getTrustDetails() {
    return _remoteDataSource.getTrustDetails();
  }
}
