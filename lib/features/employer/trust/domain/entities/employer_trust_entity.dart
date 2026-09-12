import 'package:flutter/foundation.dart';

@immutable
class EmployerTrustEntity {
  const EmployerTrustEntity({
    required this.isTrusted,
    required this.successfulJobs,
    required this.cancellationCount,
    required this.isGoodStanding,
    required this.trustRequirementsMet,
    required this.successfulJobsRequired,
    required this.maxCancellationsForTrust,
    required this.jobsRequiredToRegainTrust,
  });

  final bool isTrusted;
  final int successfulJobs;
  final int cancellationCount;
  final bool isGoodStanding;
  final bool trustRequirementsMet;
  final int successfulJobsRequired;
  final int maxCancellationsForTrust;
  final int jobsRequiredToRegainTrust;

  String get statusTitle => isTrusted ? 'Trusted Employer' : 'Untrusted Employer';

  String get statusDescription => isTrusted
      ? 'You are a trusted member of the Patch Bro community.'
      : 'Your account currently does not meet our trust requirements.';

  String get cancellationLabel =>
      cancellationCount == 1 ? '1 cancellation' : '$cancellationCount cancellations';

  String get successfulJobsLabel => '$successfulJobs successful jobs';

  String get standingLabel => isGoodStanding ? 'Good standing' : 'Needs improvement';
}
