import 'dart:io';

enum PostJobStatus {
  initial,
  submitting,
  success,
  failure,
}

class PostJobState {
  final PostJobStatus status;
  final String? errorMessage;

  final String category;
  final String skill;

  final DateTime? selectedDate;
  final DateTime? selectedTime;

  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  final String description;

  final File? voiceRecording;
  final Duration recordingDuration;
  final bool isRecording;

  final List<File> images;

  const PostJobState({
    this.status = PostJobStatus.initial,
    this.errorMessage,
    this.category = '',
    this.skill = '',
    this.selectedDate,
    this.selectedTime,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.description = '',
    this.voiceRecording,
    this.recordingDuration = Duration.zero,
    this.isRecording = false,
    this.images = const [],
  });

  PostJobState copyWith({
    PostJobStatus? status,
    String? errorMessage,
    bool clearError = false,
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
    Duration? recordingDuration,
    bool? isRecording,
    List<File>? images,
  }) {
    return PostJobState(
      status: status ?? this.status,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      category: category ?? this.category,
      skill: skill ?? this.skill,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      description: description ?? this.description,
      voiceRecording: clearVoiceRecording
          ? null
          : voiceRecording ?? this.voiceRecording,
      recordingDuration:
          recordingDuration ?? this.recordingDuration,
      isRecording: isRecording ?? this.isRecording,
      images: images ?? this.images,
    );
  }
}