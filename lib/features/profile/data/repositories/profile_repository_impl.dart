import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address1,
    String? address2,
    required String pinCode,
    required String state,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required bool isWorker,
  }) {
    return _remoteDataSource.saveProfile(
      name: name,
      phone: phone,
      address1: address1,
      address2: address2,
      pinCode: pinCode,
      state: state,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      isWorker: isWorker,
    );
  }

  @override
  Future<Map<String, dynamic>?> getCurrentProfile() {
    return _remoteDataSource.getCurrentProfile();
  }

  @override
  Future<void> updateProfileLocation({
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) {
    return _remoteDataSource.updateProfileLocation(
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
    );
  }

  @override
  Future<bool> hasWorkerProfile() {
    return _remoteDataSource.hasWorkerProfile();
  }

  @override
  Future<bool> hasEmployerProfile() {
    return _remoteDataSource.hasEmployerProfile();
  }
}