import 'package:flutter/foundation.dart';

enum JobInvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
  cancelled,
}

@immutable
class JobInvitationEntity {
  const JobInvitationEntity({
    required this.id,
    required this.jobId,
    required this.employerId,
    required this.workerId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    this.workerName = '',
    this.workerPhone = '',
    this.workerAvatarUrl,
    this.employerName = '',
    this.jobCategory = '',
    this.jobSkill = '',
    this.scheduledDate,
    this.scheduledTime = '',
    this.locationAddress = '',
    this.description = '',
  });

  final String id;
  final String jobId;
  final String employerId;
  final String workerId;

  final JobInvitationStatus status;

  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  final String workerName;
  final String workerPhone;
  final String? workerAvatarUrl;

  final String employerName;

  final String jobCategory;
  final String jobSkill;

  final DateTime? scheduledDate;
  final String scheduledTime;

  final String locationAddress;
  final String description;

  bool get isPending =>
      status == JobInvitationStatus.pending;

  bool get isActive =>
      isPending && expiresAt.isAfter(DateTime.now());

  Duration get remaining {
    final difference =
        expiresAt.difference(DateTime.now());

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  String get statusLabel {
    switch (status) {
      case JobInvitationStatus.pending:
        return 'Pending';
      case JobInvitationStatus.accepted:
        return 'Accepted';
      case JobInvitationStatus.rejected:
        return 'Rejected';
      case JobInvitationStatus.expired:
        return 'Expired';
      case JobInvitationStatus.cancelled:
        return 'Cancelled';
    }
  }
}