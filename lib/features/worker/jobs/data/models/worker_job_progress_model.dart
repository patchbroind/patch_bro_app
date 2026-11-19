
import 'package:patch_bro/features/worker/jobs/domain/eintities/worker_job_progress_entity.dart';

class WorkerJobProgressModel {
  const WorkerJobProgressModel({
    required this.status,
    this.onTheWayAt,
    this.reachedAt,
  });

  final String status;
  final DateTime? onTheWayAt;
  final DateTime? reachedAt;

  factory WorkerJobProgressModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return WorkerJobProgressModel(
      status: map['worker_progress_status']?.toString() ?? 'not_started',
      onTheWayAt: DateTime.tryParse(
        map['worker_on_the_way_at']?.toString() ?? '',
      )?.toLocal(),
      reachedAt: DateTime.tryParse(
        map['worker_reached_at']?.toString() ?? '',
      )?.toLocal(),
    );
  }

  WorkerJobProgressEntity toEntity() {
    return WorkerJobProgressEntity(
      status: status,
      onTheWayAt: onTheWayAt,
      reachedAt: reachedAt,
    );
  }
}
