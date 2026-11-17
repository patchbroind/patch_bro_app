
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/worker_jobs_controller.dart';
import '../controllers/worker_jobs_state.dart';

final workerJobsControllerProvider =
    NotifierProvider<WorkerJobsController, WorkerJobsState>(
  WorkerJobsController.new,
);