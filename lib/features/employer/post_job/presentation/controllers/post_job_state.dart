import 'dart:io';

enum PostJobStatus { initial, submitting, success, failure }

/// Represents an image that already exists on the server.
///
/// [url] is used to display the image.
/// [storagePath] is sent back to the backend when the image
/// needs to be deleted.
class PostJobExistingImage {
  final String url;
  final String storagePath;
  final int sortOrder;

  const PostJobExistingImage({
    required this.url,
    required this.storagePath,
    required this.sortOrder,
  });

  PostJobExistingImage copyWith({String? url, String? storagePath, int? sortOrder}) {
    return PostJobExistingImage(
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class PostJobState {
  final PostJobStatus status;
  final String? errorMessage;

  /// Null when creating a new job.
  /// Contains the job ID when editing an existing job.
  final String? editingJobId;

  final String category;
  final String skill;

  final DateTime? selectedDate;
  final DateTime? selectedTime;

  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  final String description;

  /// New audio selected/recorded locally.
  final File? voiceRecording;

  /// Existing audio URL from the backend.
  final String? existingAudioUrl;

  /// Existing audio storage path.
  ///
  /// This is required by the backend when deleting/replacing
  /// the existing audio.
  final String? existingAudioPath;

  /// Whether the existing server-side audio should be deleted.
  final bool removeExistingAudio;

  final Duration recordingDuration;
  final bool isRecording;

  /// New images selected locally.
  final List<File> images;

  /// Images that already exist on the server.
  final List<PostJobExistingImage> existingImages;

  /// Storage paths of existing images that the user removed
  /// while editing the job.
  final List<String> deletedImagePaths;

  const PostJobState({
    this.status = PostJobStatus.initial,
    this.errorMessage,

    this.editingJobId,

    this.category = '',
    this.skill = '',

    this.selectedDate,
    this.selectedTime,

    this.latitude,
    this.longitude,
    this.locationAddress,

    this.description = '',

    this.voiceRecording,

    this.existingAudioUrl,
    this.existingAudioPath,
    this.removeExistingAudio = false,

    this.recordingDuration = Duration.zero,
    this.isRecording = false,

    this.images = const [],

    this.existingImages = const [],
    this.deletedImagePaths = const [],
  });

  /// Whether this state represents an existing job being edited.
  bool get isEditMode => editingJobId != null;

  /// Number of images currently displayed/kept in the form.
  int get totalImageCount => existingImages.length + images.length;

  /// Maximum number of additional local images that can be added.
  int get remainingImageSlots {
    final remaining = 2 - totalImageCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Whether the form can still accept another image.
  bool get canAddImage => totalImageCount < 2;

  /// Whether there is an existing server-side audio
  /// that has not been removed.
  bool get hasExistingAudio => existingAudioUrl != null && !removeExistingAudio;

  /// Whether the job currently has any audio attached
  /// or being added.
  bool get hasAnyAudio => voiceRecording != null || hasExistingAudio;

  PostJobState copyWith({
    PostJobStatus? status,
    String? errorMessage,
    bool clearError = false,

    String? editingJobId,
    bool clearEditingJobId = false,

    String? category,
    String? skill,

    DateTime? selectedDate,
    DateTime? selectedTime,

    double? latitude,
    double? longitude,
    String? locationAddress,

    String? description,

    File? voiceRecording,
    bool clearVoiceRecording = false,

    String? existingAudioUrl,
    bool clearExistingAudioUrl = false,

    String? existingAudioPath,
    bool clearExistingAudioPath = false,

    bool? removeExistingAudio,

    Duration? recordingDuration,
    bool? isRecording,

    List<File>? images,

    List<PostJobExistingImage>? existingImages,

    List<String>? deletedImagePaths,
  }) {
    return PostJobState(
      status: status ?? this.status,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,

      editingJobId: clearEditingJobId ? null : editingJobId ?? this.editingJobId,

      category: category ?? this.category,
      skill: skill ?? this.skill,

      selectedDate: selectedDate ?? this.selectedDate,

      selectedTime: selectedTime ?? this.selectedTime,

      latitude: latitude ?? this.latitude,

      longitude: longitude ?? this.longitude,

      locationAddress: locationAddress ?? this.locationAddress,

      description: description ?? this.description,

      voiceRecording: clearVoiceRecording ? null : voiceRecording ?? this.voiceRecording,

      existingAudioUrl: clearExistingAudioUrl ? null : existingAudioUrl ?? this.existingAudioUrl,

      existingAudioPath: clearExistingAudioPath
          ? null
          : existingAudioPath ?? this.existingAudioPath,

      removeExistingAudio: removeExistingAudio ?? this.removeExistingAudio,

      recordingDuration: recordingDuration ?? this.recordingDuration,

      isRecording: isRecording ?? this.isRecording,

      images: images ?? this.images,

      existingImages: existingImages ?? this.existingImages,

      deletedImagePaths: deletedImagePaths ?? this.deletedImagePaths,
    );
  }
}
