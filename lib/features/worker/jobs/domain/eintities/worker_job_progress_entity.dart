
import 'package:flutter/foundation.dart';

@immutable
class WorkerJobProgressEntity {
  const WorkerJobProgressEntity({
    required this.status,
    this.onTheWayAt,
    this.reachedAt,
  });

  final String status;
  final DateTime? onTheWayAt;
  final DateTime? reachedAt;
}
