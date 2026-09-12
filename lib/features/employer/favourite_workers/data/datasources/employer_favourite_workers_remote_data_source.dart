import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/favourite_worker_entity.dart';

class EmployerFavouriteWorkersRemoteDataSource {
  EmployerFavouriteWorkersRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<FavouriteWorkerEntity>> getFavouriteWorkers() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    /*
     * Temporary backend boundary: current migrations do not define a
     * favourite relationship, worker-facing profile fields, ratings, or
     * reviews. Do not guess table/column/RPC names; replace this method when
     * that backend contract is available.
     */
    return const <FavouriteWorkerEntity>[ 
    //.........................temporary data.............

      FavouriteWorkerEntity(id: "1", name: "John", profession: "Painter", rating: 5.5, reviewCount: 7),FavouriteWorkerEntity(id: "2", name: "Ram", profession: "Cleaning", rating: 7.5, reviewCount: 9)
    //.........................temporary data.............
    ];
  }

  Future<void> toggleFavourite(String workerId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    throw UnsupportedError(
      'Favourite worker persistence is unavailable until the backend schema is added.',
    );
  }
}
