import '../entities/employer_address_entity.dart';

abstract interface class EmployerAddressesRepository {
  Future<List<EmployerAddressEntity>> getAddresses();
}
