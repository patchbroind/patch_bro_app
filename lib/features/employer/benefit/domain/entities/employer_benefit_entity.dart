import 'package:flutter/foundation.dart';

@immutable
class EmployerBenefitEntity {
  const EmployerBenefitEntity({
    required this.qualifyingWorkerJobs,
    required this.requiredWorkerJobs,
    required this.isEligible,
    required this.benefitTitle,
    required this.benefitDescription,
    required this.remainingJobsDescription,
  });

  final int qualifyingWorkerJobs;
  final int requiredWorkerJobs;
  final bool isEligible;
  final String benefitTitle;
  final String benefitDescription;
  final String remainingJobsDescription;

  double get progress {
    if (requiredWorkerJobs <= 0) {
      return 0;
    }

    return (qualifyingWorkerJobs / requiredWorkerJobs).clamp(0.0, 1.0);
  }

  int get remainingJobs {
    final remaining = requiredWorkerJobs - qualifyingWorkerJobs;
    return remaining > 0 ? remaining : 0;
  }

  String get progressLabel => '$qualifyingWorkerJobs / $requiredWorkerJobs';
}
