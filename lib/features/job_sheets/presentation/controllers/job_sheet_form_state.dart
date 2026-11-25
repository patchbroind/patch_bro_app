
class JobSheetFormState {
  const JobSheetFormState({
    this.imagePaths = const [],
    this.audioPath,
    this.isRecording = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<String> imagePaths;
  final String? audioPath;
  final bool isRecording;
  final bool isSubmitting;
  final String? errorMessage;

  JobSheetFormState copyWith({
    List<String>? imagePaths,
    String? audioPath,
    bool clearAudio = false,
    bool? isRecording,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobSheetFormState(
      imagePaths: imagePaths ?? this.imagePaths,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      isRecording: isRecording ?? this.isRecording,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}