import '../../domain/entities/employer_address_entity.dart';
import '../../domain/repository/employer_addresses_repository.dart';
import '../datasources/employer_addresses_remote_data_source.dart';

class EmployerAddressesRepositoryImpl implements EmployerAddressesRepository {
  EmployerAddressesRepositoryImpl(this._remoteDataSource);

  final EmployerAddressesRemoteDataSource _remoteDataSource;

  @override
  Future<List<EmployerAddressEntity>> getAddresses() {
    return _remoteDataSource.getAddresses();
  }
}
