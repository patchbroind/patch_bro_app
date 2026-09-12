import 'package:flutter/foundation.dart';

@immutable
class EmployerProfileEntity {
  const EmployerProfileEntity({
    required this.id,
    required this.fullName,
    required this.roleLabel,
    required this.isTrusted,
    required this.jobsPosted,
    required this.jobsCompleted,
    required this.cancelledJobs,
    required this.successfulJobs,
    required this.hasWorkerProfile,
    required this.qualifyingWorkerJobs,
    required this.requiredWorkerJobs,
    this.avatarUrl,
    this.platformFeeBenefitEligible = false,
  });

  final String id;
  final String fullName;
  final String roleLabel;
  final String? avatarUrl;

  final bool isTrusted;

  final int jobsPosted;
  final int jobsCompleted;
  final int cancelledJobs;
  final int successfulJobs;

  final bool hasWorkerProfile;

  final int qualifyingWorkerJobs;
  final int requiredWorkerJobs;

  final bool platformFeeBenefitEligible;

  double get workerBenefitProgress {
    if (requiredWorkerJobs <= 0) {
      return 0;
    }

    return (qualifyingWorkerJobs / requiredWorkerJobs).clamp(
      0.0,
      1.0,
    );
  }

  int get remainingWorkerJobs {
    return (requiredWorkerJobs - qualifyingWorkerJobs).clamp(
      0,
      requiredWorkerJobs,
    );
  }
}