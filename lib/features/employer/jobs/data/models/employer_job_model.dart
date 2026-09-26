import '../../domain/entities/employer_job_entity.dart';

class EmployerJobModel {
  const EmployerJobModel({
    required this.id,
    required this.category,
    required this.skill,
    required this.date,
    required this.time,
    required this.locationAddress,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.imageUrls = const [],
    this.imagePaths = const [],
    this.audioUrl,
    this.audioPath,
  });

  final String id;
  final String category;
  final String skill;
  final DateTime date;
  final DateTime time;
  final String locationAddress;
  final String description;
  final EmployerJobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final double? latitude;
  final double? longitude;

  final String? imageUrl;
  final List<String> imageUrls;
  final List<String> imagePaths;

  final String? audioUrl;
  final String? audioPath;

  factory EmployerJobModel.fromJson(Map<String, dynamic> json) {
    final imageMedia = _parseImageMedia(json['image_media']);

    final parsedImageUrls = _parseStringList(json['image_urls']);

    final imageUrls = parsedImageUrls.isNotEmpty
        ? parsedImageUrls
        : imageMedia.map((item) => item.url).toList();

    final imagePaths = imageMedia.map((item) => item.storagePath).toList();

    final imageUrl =
        _toNullableString(json['image_url']) ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

    return EmployerJobModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      skill: json['skill']?.toString() ?? '',
      date: _parseDate(json['scheduled_date']),
      time: _parseTime(json['scheduled_time']),
      locationAddress: json['location_address']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: _parseStatus(json['status']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      imagePaths: imagePaths,
      audioUrl: _toNullableString(json['audio_url']),
      audioPath: _toNullableString(json['audio_storage_path']),
    );
  }

  EmployerJobEntity toEntity() {
    return EmployerJobEntity(
      id: id,
      category: category,
      skill: skill,
      date: date,
      time: time,
      locationAddress: locationAddress,
      description: description,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      imageUrls: List.unmodifiable(imageUrls),
      imagePaths: List.unmodifiable(imagePaths),
      audioUrl: audioUrl,
      audioPath: audioPath,
    );
  }

  // ===========================================================================
  // PARSERS
  // ===========================================================================

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<_ImageMediaData> _parseImageMedia(dynamic value) {
    if (value is! List) {
      return const [];
    }

    final result = <_ImageMediaData>[];

    for (final item in value) {
      if (item is! Map) {
        continue;
      }

      final url = _toNullableString(item['url']);

      final storagePath = _toNullableString(item['storage_path']);

      if (url == null || storagePath == null) {
        continue;
      }

      result.add(_ImageMediaData(url: url, storagePath: storagePath));
    }

    return result;
  }

  static DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw const FormatException('Invalid job scheduled date.');
    }

    return parsed;
  }

  static DateTime _parseDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw const FormatException('Invalid job timestamp.');
    }

    return parsed.toLocal();
  }

  static DateTime _parseTime(dynamic value) {
    final stringValue = value?.toString() ?? '';

    final parts = stringValue.split(':');

    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;

    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    final second = int.tryParse(parts.length > 2 ? parts[2] : '') ?? 0;

    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  static EmployerJobStatus _parseStatus(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'open':
      case 'pending':
      case 'assigned':
      case 'accepted':
      case 'in_progress':
      case 'in-progress':
        return EmployerJobStatus.active;

      case 'completed':
        return EmployerJobStatus.completed;

      case 'cancelled':
      case 'canceled':
        return EmployerJobStatus.cancelled;

      default:
        return EmployerJobStatus.active;
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    return double.tryParse(value.toString());
  }

  static String? _toNullableString(dynamic value) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }
}

class _ImageMediaData {
  const _ImageMediaData({required this.url, required this.storagePath});

  final String url;
  final String storagePath;
}
