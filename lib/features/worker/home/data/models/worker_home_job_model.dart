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
    this.scheduledSlotIds = const [],
    this.latitude,
    this.longitude,
    this.description = '',
    this.imageUrl,
    this.imageUrls = const [],
    this.audioUrl,
    this.audioStoragePath,
    this.createdAt,
    this.updatedAt,
    this.workerProgressStatus = 'not_started',
    this.workerOnTheWayAt,
    this.workerReachedAt,
  });

  final String id;
  final String category;
  final String skill;
  final String locationAddress;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String status;

  final List<String> scheduledSlotIds;
  final double? latitude;
  final double? longitude;
  final String description;

  final String? imageUrl;
  final List<String> imageUrls;

  final String? audioUrl;
  final String? audioStoragePath;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String workerProgressStatus;
  final DateTime? workerOnTheWayAt;
  final DateTime? workerReachedAt;

  factory WorkerHomeJobModel.fromMap(Map<String, dynamic> map) {
    final scheduledDate = DateTime.tryParse(map['scheduled_date']?.toString() ?? '');

    if (scheduledDate == null) {
      throw const FormatException('Invalid scheduled date received for worker job.');
    }

    return WorkerHomeJobModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      skill: map['skill']?.toString() ?? '',
      locationAddress: map['location_address']?.toString() ?? '',
      scheduledDate: scheduledDate,
      scheduledTime: map['scheduled_time']?.toString() ?? '',
      status: map['status']?.toString() ?? '',

      scheduledSlotIds: _parseStringList(map['scheduled_slots']),

      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),

      description: map['description']?.toString() ?? '',

      imageUrl: _nullableString(map['image_url']),
      imageUrls: _parseStringList(map['image_urls']),

      audioUrl: _nullableString(map['audio_url']),
      audioStoragePath: _nullableString(map['audio_storage_path']),

      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),

      workerProgressStatus: map['worker_progress_status']?.toString() ?? 'not_started',

      workerOnTheWayAt: DateTime.tryParse(map['worker_on_the_way_at']?.toString() ?? '')?.toLocal(),

      workerReachedAt: DateTime.tryParse(map['worker_reached_at']?.toString() ?? '')?.toLocal(),
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
      scheduledSlotIds: List.unmodifiable(scheduledSlotIds),
      latitude: latitude,
      longitude: longitude,
      description: description,
      imageUrl: imageUrl,
      imageUrls: List.unmodifiable(imageUrls),
      audioUrl: audioUrl,
      audioStoragePath: audioStoragePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      workerProgressStatus: workerProgressStatus,
      workerOnTheWayAt: workerOnTheWayAt,
      workerReachedAt: workerReachedAt,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) return null;

    return text;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed?.toLocal();
  }
}
