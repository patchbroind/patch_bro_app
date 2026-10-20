import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patch_bro/features/employer/invitations/presentation/providers/employer_invitations_providers.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:record/record.dart';

import '../../../../profile/domain/entities/profile_location.dart';
import '../../domain/repositories/post_job_repository.dart';
import '../providers/post_job_providers.dart';
import 'post_job_state.dart';

class PostJobSubmissionResult {
  const PostJobSubmissionResult({required this.jobId, required this.failedWorkers});

  final String? jobId;
  final List<EmployerWorkerEntity> failedWorkers;

  bool get jobCreated => jobId != null;
}

class PostJobController extends Notifier<PostJobState> {
  late final PostJobRepository _repository;

  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _invitationBatchInProgress = false;

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

  bool toggleSelectedWorker(String workerId) {
    final selected = [...state.selectedWorkerIds];
    if (selected.contains(workerId)) {
      selected.remove(workerId);
    } else {
      if (selected.length >= 5) return false;
      selected.add(workerId);
    }
    state = state.copyWith(
      selectedWorkerIds: selected,
      status: PostJobStatus.initial,
      clearError: true,
    );
    return true;
  }

  void reconcileSelectedWorkers(Set<String> eligibleWorkerIds) {
    final eligibleSelections = state.selectedWorkerIds
        .where(eligibleWorkerIds.contains)
        .toSet()
        .toList(growable: false);
    if (eligibleSelections.length != state.selectedWorkerIds.length) {
      state = state.copyWith(selectedWorkerIds: eligibleSelections);
    }
  }

  void setActiveWorkerCardIndex(int index) {
    final nextIndex = index < 0 ? 0 : index;
    if (nextIndex != state.activeWorkerCardIndex) {
      state = state.copyWith(activeWorkerCardIndex: nextIndex);
    }
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

  /// Starts an isolated create-job session. This is intentionally separate
  /// from [reset] so the home-category entry point can preselect a category.
  void startCreateSession({String? category}) {
    state = PostJobState(
      category: category?.trim() ?? '',
      createSessionId: state.createSessionId + 1,
    );
  }

  void goToPreviousStep() {
    if (state.currentStep == 0 || state.status == PostJobStatus.submitting) {
      return;
    }

    state = state.copyWith(
      currentStep: state.currentStep - 1,
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

  /// Validates only the visible create-job step and advances when valid.
  bool goToNextStep() {
    if (state.status == PostJobStatus.submitting || state.currentStep >= 5) {
      return false;
    }

    final validationError = validateStep(state.currentStep);

    if (validationError != null) {
      state = state.copyWith(status: PostJobStatus.failure, errorMessage: validationError);
      return false;
    }

    state = state.copyWith(
      currentStep: state.currentStep + 1,
      status: PostJobStatus.initial,
      clearError: true,
    );
    return true;
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

  String? validateStep(int step) {
    switch (step) {
      case 0:
        if (state.category.trim().isEmpty) {
          return 'Please select a category.';
        }
        // The current API stores one required-skill string; do not fabricate a
        // multi-skill payload until the backend supplies that contract.
        if (state.skill.trim().isEmpty) {
          return 'Please enter the required skill.';
        }
        return null;
      case 1:
        if (state.selectedDate == null) {
          return 'Please select the job date.';
        }
        if (state.selectedTime == null) {
          return 'Please select the job time.';
        }
        return null;
      case 2:
        if (state.locationAddress == null || state.locationAddress!.trim().isEmpty) {
          return 'Please select the job location.';
        }
        if (state.latitude == null || state.longitude == null) {
          return 'Please select a valid job location.';
        }
        return null;
      case 3:
        if (state.description.trim().isEmpty &&
            state.voiceRecording == null &&
            !state.hasExistingAudio) {
          return 'Please add a text or voice description.';
        }
        return null;
      case 4:
        if (state.totalImageCount > 2) {
          return 'You can add a maximum of 2 images.';
        }
        return null;
      case 5:
        if (state.selectedWorkerIds.isEmpty) {
          return 'Please select at least one worker.';
        }
        if (state.selectedWorkerIds.length > 5) {
          return 'You can select up to 5 workers.';
        }
        return null;
    }
    return null;
  }

  String? _validate() {
    for (var step = 0; step < 5; step++) {
      final error = validateStep(step);
      if (error != null) return error;
    }
    if (!state.isEditMode) {
      final workerError = validateStep(5);
      if (workerError != null) return workerError;
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
    if (state.status == PostJobStatus.submitting) {
      return null;
    }

    if (!state.isEditMode && state.createdJobId != null) {
      state = state.copyWith(
        status: PostJobStatus.failure,
        errorMessage: 'This job has already been posted.',
      );
      return null;
    }

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

      if (jobId == null || jobId.trim().isEmpty) {
        state = state.copyWith(
          status: PostJobStatus.failure,
          errorMessage: 'The job could not be created because the server returned no job ID.',
        );
        return null;
      }

      state = state.copyWith(status: PostJobStatus.success, createdJobId: jobId, clearError: true);

      return jobId;
    } catch (e) {
      state = state.copyWith(status: PostJobStatus.failure, errorMessage: e.toString());

      return null;
    }
  }

  Future<PostJobSubmissionResult> submitAndInviteWorkers(List<EmployerWorkerEntity> workers) async {
    final workerIds = workers.map((worker) => worker.id).toSet();
    if (workers.isEmpty ||
        workers.length > 5 ||
        workerIds.length != workers.length ||
        state.selectedWorkerIds.length != workers.length ||
        !state.selectedWorkerIds.toSet().containsAll(workerIds)) {
      state = state.copyWith(
        status: PostJobStatus.failure,
        errorMessage: 'Select between 1 and 5 distinct eligible workers.',
      );
      return const PostJobSubmissionResult(jobId: null, failedWorkers: []);
    }

    final jobId = await submitJob();
    if (jobId == null || jobId.trim().isEmpty) {
      return const PostJobSubmissionResult(jobId: null, failedWorkers: []);
    }

    final failures = await _inviteWorkers(jobId, workers);
    return PostJobSubmissionResult(jobId: jobId, failedWorkers: failures);
  }

  Future<List<EmployerWorkerEntity>> retryFailedWorkerInvitations({
    required String jobId,
    required List<EmployerWorkerEntity> failedWorkers,
  }) {
    if (state.createdJobId != jobId || jobId.trim().isEmpty) {
      throw StateError('Cannot retry invitations without the created job ID.');
    }
    return _inviteWorkers(jobId, failedWorkers);
  }

  Future<List<EmployerWorkerEntity>> _inviteWorkers(
    String jobId,
    List<EmployerWorkerEntity> workers,
  ) async {
    if (_invitationBatchInProgress) {
      throw StateError('Worker invitations are already being processed.');
    }
    _invitationBatchInProgress = true;
    final failures = <EmployerWorkerEntity>[];
    try {
      final controller = ref.read(employerInvitationsControllerProvider(jobId).notifier);
      for (final worker in workers) {
        try {
          await controller.inviteWorker(worker.id);
        } catch (error) {
          debugPrint('Invitation for worker ${worker.id} failed: $error');
          failures.add(worker);
        }
      }
      return failures;
    } finally {
      _invitationBatchInProgress = false;
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    state = PostJobState(createSessionId: state.createSessionId + 1);
  }
}
