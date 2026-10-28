import '../../domain/entities/worker_home_job_entity.dart';

class WorkerHomeJobModel {
  const WorkerHomeJobModel({
    required this.id,
    required this.category,
    required this.skill,
    required this.locationAddress,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String category;
  final String skill;
  final String locationAddress;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String status;
  final String? imageUrl;

  factory WorkerHomeJobModel.fromMap(Map<String, dynamic> map) {
    final dateValue = map['scheduled_date'];
    final date = DateTime.tryParse(dateValue?.toString() ?? '') ?? DateTime.now();

    return WorkerHomeJobModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      skill: map['skill']?.toString() ?? '',
      locationAddress: map['location_address']?.toString() ?? '',
      scheduledDate: date,
      scheduledTime: map['scheduled_time']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      imageUrl: _nullableString(map['image_url']) ?? _nullableString(map['image_urls'] is List ? (map['image_urls'] as List).firstOrNull : null),
    );
  }

  WorkerHomeJobEntity toEntity() {
    return WorkerHomeJobEntity(
      id: id,
      title: skill,
      category: category,
      locationAddress: locationAddress,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      status: status,
      imageUrl: imageUrl,
    );
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
