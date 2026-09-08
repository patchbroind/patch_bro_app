abstract interface class ProfileRepository {
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
  });

  Future<bool> hasWorkerProfile();

  Future<bool> hasEmployerProfile();
}