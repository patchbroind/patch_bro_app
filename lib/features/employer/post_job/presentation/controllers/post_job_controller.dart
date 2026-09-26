import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:record/record.dart';

import '../../../../profile/domain/entities/profile_location.dart';
import '../../domain/repositories/post_job_repository.dart';
import '../providers/post_job_providers.dart';
import 'post_job_state.dart';

class PostJobController extends Notifier<PostJobState> {
  late final PostJobRepository _repository;

  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  @override
  PostJobState build() {
    _repository = ref.read(postJobRepositoryProvider);

    ref.onDispose(() {
      _audioRecorder.dispose();
    });

    return const PostJobState();
  }

  // ---------------------------------------------------------------------------
  // FORM FIELDS
  // ---------------------------------------------------------------------------

  void setCategory(String value) {
    state = state.copyWith(category: value, status: PostJobStatus.initial, clearError: true);
  }

  void setSkill(String value) {
    state = state.copyWith(skill: value, status: PostJobStatus.initial, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date, status: PostJobStatus.initial, clearError: true);
  }

  void setTime(DateTime time) {
    state = state.copyWith(selectedTime: time, status: PostJobStatus.initial, clearError: true);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value, status: PostJobStatus.initial, clearError: true);
  }

  void setLocation(ProfileLocation location) {
    state = state.copyWith(
      latitude: location.latitude,
      longitude: location.longitude,
      locationAddress: location.address,
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // EDIT MODE INITIALIZATION
  // ---------------------------------------------------------------------------

  /// Prefills the Post Job form with an existing job.
  ///
  /// This is called when Job Details -> Edit Job is opened.
  void initializeForEdit(EmployerJobEntity job) {
    final existingImages = <PostJobExistingImage>[];

    if (job.imageUrls.isNotEmpty) {
      for (var index = 0; index < job.imageUrls.length; index++) {
        final imageUrl = job.imageUrls[index];

        if (imageUrl.trim().isEmpty) {
          continue;
        }

        existingImages.add(
          PostJobExistingImage(
            url: imageUrl,
            storagePath: job.imagePaths.length > index ? job.imagePaths[index] : '',
            sortOrder: index,
          ),
        );
      }
    } else if (job.imageUrl != null && job.imageUrl!.trim().isNotEmpty) {
      existingImages.add(
        PostJobExistingImage(
          url: job.imageUrl!,
          storagePath: job.imagePaths.isNotEmpty ? job.imagePaths.first : '',
          sortOrder: 0,
        ),
      );
    }

    state = PostJobState(
      editingJobId: job.id,
      category: job.category,
      skill: job.skill,
      selectedDate: job.date,
      selectedTime: job.time,
      latitude: job.latitude,
      longitude: job.longitude,
      locationAddress: job.locationAddress,
      description: job.description,
      existingAudioUrl: job.audioUrl,
      existingAudioPath: job.audioPath,
      existingImages: existingImages,
      images: const [],
      deletedImagePaths: const [],
      status: PostJobStatus.initial,
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGES
  // ---------------------------------------------------------------------------

  Future<void> pickImages() async {
    if (!state.canAddImage) {
      return;
    }

    final remaining = state.remainingImageSlots;

    if (remaining <= 0) {
      return;
    }

    final pickedImages = await _imagePicker.pickMultiImage(imageQuality: 85, limit: remaining);

    if (pickedImages.isEmpty) {
      return;
    }

    final selected = pickedImages.take(remaining).map((image) => File(image.path)).toList();

    state = state.copyWith(
      images: [...state.images, ...selected],
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

  /// Removes a newly selected local image.
  Future<void> removeImage(int index) async {
    if (index < 0 || index >= state.images.length) {
      return;
    }

    final updatedImages = [...state.images];

    updatedImages.removeAt(index);

    state = state.copyWith(images: updatedImages, status: PostJobStatus.initial, clearError: true);
  }

  /// Removes an existing server-side image.
  ///
  /// The image isn't immediately deleted from Supabase.
  /// Its storage path is added to [deletedImagePaths].
  ///
  /// The backend deletes it when the user saves the edit.
  void removeExistingImage(int index) {
    if (index < 0 || index >= state.existingImages.length) {
      return;
    }

    final image = state.existingImages[index];

    final updatedImages = [...state.existingImages];

    updatedImages.removeAt(index);

    final updatedDeletedPaths = [...state.deletedImagePaths];

    if (image.storagePath.trim().isNotEmpty && !updatedDeletedPaths.contains(image.storagePath)) {
      updatedDeletedPaths.add(image.storagePath);
    }

    state = state.copyWith(
      existingImages: updatedImages,
      deletedImagePaths: updatedDeletedPaths,
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // VOICE RECORDING
  // ---------------------------------------------------------------------------

  void updateRecordingDuration(Duration duration) {
    if (!state.isRecording) {
      return;
    }

    state = state.copyWith(recordingDuration: duration);
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        state = state.copyWith(
          status: PostJobStatus.failure,
          errorMessage: 'Microphone permission is required to record a voice description.',
        );
        return;
      }

      final recordingPath =
          '${Directory.systemTemp.path}/patch_bro_job_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: recordingPath,
      );

      state = state.copyWith(
        isRecording: true,
        recordingDuration: Duration.zero,
        status: PostJobStatus.initial,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isRecording: false,
        status: PostJobStatus.failure,
        errorMessage: 'Unable to start voice recording.',
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      if (path == null || path.isEmpty) {
        state = state.copyWith(
          isRecording: false,
          status: PostJobStatus.failure,
          errorMessage: 'No recording was created.',
        );
        return;
      }

      state = state.copyWith(
        isRecording: false,
        voiceRecording: File(path),
        recordingDuration: state.recordingDuration,
        status: PostJobStatus.initial,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isRecording: false,
        status: PostJobStatus.failure,
        errorMessage: 'Unable to stop voice recording.',
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.cancel();

      state = state.copyWith(
        isRecording: false,
        recordingDuration: Duration.zero,
        status: PostJobStatus.initial,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(isRecording: false);
    }
  }

  /// Removes a newly recorded local voice file.
  ///
  /// If an existing server audio file exists,
  /// this also marks that existing audio for deletion.
  void removeVoiceRecording() {
    state = state.copyWith(
      clearVoiceRecording: true,
      recordingDuration: Duration.zero,
      removeExistingAudio: state.existingAudioUrl != null,
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

  /// Explicitly removes the existing server-side voice.
  void removeExistingVoice() {
    state = state.copyWith(
      removeExistingAudio: true,
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------------------

  String? _validate() {
    if (state.category.trim().isEmpty) {
      return 'Please select a category.';
    }

    if (state.skill.trim().isEmpty) {
      return 'Please enter the required skill.';
    }

    if (state.selectedDate == null) {
      return 'Please select the job date.';
    }

    if (state.selectedTime == null) {
      return 'Please select the job time.';
    }

    if (state.locationAddress == null || state.locationAddress!.trim().isEmpty) {
      return 'Please select the job location.';
    }

    if (state.latitude == null || state.longitude == null) {
      return 'Please select a valid job location.';
    }

    final hasTextDescription = state.description.trim().isNotEmpty;

    final hasNewVoice = state.voiceRecording != null;

    final hasExistingVoice = state.hasExistingAudio;

    if (!hasTextDescription && !hasNewVoice && !hasExistingVoice) {
      return 'Please add a text or voice description.';
    }

    if (state.totalImageCount > 2) {
      return 'You can add a maximum of 2 images.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------

  /// Creates a new job or updates the existing job depending on the mode.
  ///
  /// NOTE:
  /// The update repository method will be added in the next step.
  Future<String?> submitJob() async {
    final validationError = _validate();

    if (validationError != null) {
      state = state.copyWith(status: PostJobStatus.failure, errorMessage: validationError);

      return null;
    }

    state = state.copyWith(status: PostJobStatus.submitting, clearError: true);

    try {
      if (state.isEditMode) {
        final keepImagePaths = state.existingImages
            .map((image) => image.storagePath)
            .where((path) => path.trim().isNotEmpty)
            .toList();

        final updatedJob = await _repository.updateJob(
          jobId: state.editingJobId!,
          category: state.category.trim(),
          skill: state.skill.trim(),
          date: state.selectedDate!,
          time: state.selectedTime!,
          latitude: state.latitude!,
          longitude: state.longitude!,
          locationAddress: state.locationAddress!,
          description: state.description.trim(),

          // Existing images that should remain.
          keepImagePaths: keepImagePaths,

          // New images selected during editing.
          newImages: state.images,

          // Existing audio storage path.
          existingAudioPath: state.existingAudioPath,

          // Delete existing audio if requested.
          removeExistingAudio: state.removeExistingAudio,

          // New audio, if recorded.
          newAudio: state.voiceRecording,
        );

        state = state.copyWith(status: PostJobStatus.success, clearError: true);

        return updatedJob.id;
      }

      final jobId = await _repository.createJob(
        category: state.category.trim(),
        skill: state.skill.trim(),
        date: state.selectedDate!,
        time: state.selectedTime!,
        latitude: state.latitude!,
        longitude: state.longitude!,
        locationAddress: state.locationAddress!,
        description: state.description.trim(),
        voiceRecording: state.voiceRecording,
        images: state.images,
      );

      state = state.copyWith(status: PostJobStatus.success, clearError: true);

      return jobId;
    } catch (e) {
      state = state.copyWith(status: PostJobStatus.failure, errorMessage: e.toString());

      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    state = const PostJobState();
  }
}
