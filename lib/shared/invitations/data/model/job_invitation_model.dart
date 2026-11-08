import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

class JobInvitationModel {
  const JobInvitationModel({
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
    this.scheduledSlotIds = const [],
    this.locationAddress = '',
    this.description = '',
    this.imageUrls = const [],
    this.audioUrl,
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
  final List<String> scheduledSlotIds;

  final String locationAddress;
  final String description;

  final List<String> imageUrls;
  final String? audioUrl;

  factory JobInvitationModel.fromMap(Map<String, dynamic> map) {
    return JobInvitationModel(
      id: map['id']?.toString() ?? '',
      jobId: map['job_id']?.toString() ?? '',
      employerId: map['employer_id']?.toString() ?? '',
      workerId: map['worker_id']?.toString() ?? '',
      status: _parseStatus(map['status']),
      createdAt: _parseDateTime(map['created_at']),
      expiresAt: _parseDateTime(map['expires_at']),
      respondedAt: _parseNullableDateTime(map['responded_at']),
      workerName: map['worker_name']?.toString() ?? '',
      workerPhone: map['worker_phone']?.toString() ?? '',
      workerAvatarUrl: _nullableString(map['worker_avatar_url']),
      employerName: map['employer_name']?.toString() ?? '',
      jobCategory: map['job_category']?.toString() ?? '',
      jobSkill: map['job_skill']?.toString() ?? '',
      scheduledDate: _parseNullableDate(map['scheduled_date']),
      scheduledTime: map['scheduled_time']?.toString() ?? '',
      scheduledSlotIds: _parseStringList(map['scheduled_slots']),
      locationAddress: map['location_address']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrls: _parseStringList(map['image_urls']),
      audioUrl: _nullableString(map['audio_url']),
    );
  }

  JobInvitationEntity toEntity() {
    return JobInvitationEntity(
      id: id,
      jobId: jobId,
      employerId: employerId,
      workerId: workerId,
      status: status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt,
      workerName: workerName,
      workerPhone: workerPhone,
      workerAvatarUrl: workerAvatarUrl,
      employerName: employerName,
      jobCategory: jobCategory,
      jobSkill: jobSkill,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      scheduledSlotIds: List.unmodifiable(scheduledSlotIds),
      locationAddress: locationAddress,
      description: description,
      imageUrls: List.unmodifiable(imageUrls),
      audioUrl: audioUrl,
    );
  }

  static JobInvitationStatus _parseStatus(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'accepted':
        return JobInvitationStatus.accepted;
      case 'rejected':
        return JobInvitationStatus.rejected;
      case 'expired':
        return JobInvitationStatus.expired;
      case 'cancelled':
      case 'canceled':
        return JobInvitationStatus.cancelled;
      case 'pending':
      default:
        return JobInvitationStatus.pending;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    final result = DateTime.tryParse(value?.toString() ?? '');

    if (result == null) {
      throw const FormatException('Invalid invitation timestamp.');
    }

    return result.toLocal();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _nullableString(dynamic value) {
    final result = value?.toString().trim();
    return result == null || result.isEmpty ? null : result;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}