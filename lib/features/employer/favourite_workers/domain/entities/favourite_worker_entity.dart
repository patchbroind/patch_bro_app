import 'package:flutter/foundation.dart';

@immutable
class FavouriteWorkerEntity {
  const FavouriteWorkerEntity({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String profession;
  final double? rating;
  final int? reviewCount;
  final String? avatarUrl;
}
