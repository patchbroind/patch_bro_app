
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patch_bro/features/job_sheets/domain/entities/job_sheet_entity.dart';
import 'package:patch_bro/features/job_sheets/domain/repositories/job_sheet_repository.dart';
import 'package:record/record.dart';
import '../providers/job_sheet_providers.dart';
import 'job_sheet_form_state.dart';

class JobSheetFormController extends Notifier<JobSheetFormState> {
  JobSheetFormController(this.jobId);

  final String jobId;

  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  late JobSheetRepository _repository;

  @override
  JobSheetFormState build() {
    _repository = ref.read(jobSheetRepositoryProvider);

    ref.onDispose(() {
      _audioRecorder.dispose();
    });

    return const JobSheetFormState();
  }

  // ------------------------------------------------------------
  // IMAGES
  // ------------------------------------------------------------

  Future<void> pickImages() async {
    if (state.imagePaths.length >= 5) return;

    try {
      final remaining = 5 - state.imagePaths.length;

      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        limit: remaining,
      );

      if (images.isEmpty) return;

      final paths = images
          .take(remaining)
          .map((image) => image.path)
          .toList();

      state = state.copyWith(
        imagePaths: [...state.imagePaths, ...paths],
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to select images: $error',
      );
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.imagePaths.length) return;

    final updated = [...state.imagePaths]..removeAt(index);

    state = state.copyWith(
      imagePaths: updated,
      clearError: true,
    );
  }

  // ------------------------------------------------------------
  // VOICE RECORDING
  // ------------------------------------------------------------

  Future<void> startRecording() async {
    if (state.isRecording || state.isSubmitting) return;

    try {
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        state = state.copyWith(
          errorMessage: 'Microphone permission is required.',
        );
        return;
      }

      final path =
          '${Directory.systemTemp.path}/job_sheet_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      state = state.copyWith(
        isRecording: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: 'Unable to start recording: $error',
      );
    }
  }

  Future<void> stopRecording() async {
    if (!state.isRecording) return;

    try {
      final path = await _audioRecorder.stop();

      if (path == null || path.isEmpty) {
        state = state.copyWith(
          isRecording: false,
          errorMessage: 'No recording was saved.',
        );
        return;
      }

      state = state.copyWith(
        audioPath: path,
        isRecording: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: 'Unable to save recording: $error',
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.cancel();
    } catch (_) {}

    state = state.copyWith(
      isRecording: false,
      clearError: true,
    );
  }

  void removeAudio() {
    state = state.copyWith(
      clearAudio: true,
      clearError: true,
    );
  }

  // ------------------------------------------------------------
  // SUBMIT
  // ------------------------------------------------------------

  Future<JobSheetEntity?> submit({
    required String workSummary,
    String? additionalNotes,
    String? materialsUsed,
  }) async {
    if (state.isSubmitting) return null;

    final summary = workSummary.trim();

    if (summary.length < 5) {
      state = state.copyWith(
        errorMessage: 'Work summary must contain at least 5 characters.',
      );
      return null;
    }

    if (state.isRecording) {
      state = state.copyWith(
        errorMessage: 'Please stop recording before submitting.',
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final result = await _repository.submitJobSheet(
        JobSheetSubmission(
          jobId: jobId,
          workSummary: summary,
          additionalNotes: additionalNotes?.trim(),
          materialsUsed: materialsUsed?.trim(),
          imagePaths: state.imagePaths,
          audioPath: state.audioPath,
        ),
      );

      ref.invalidate(jobSheetProvider(jobId));

      state = state.copyWith(
        isSubmitting: false,
        clearError: true,
      );

      return result;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );

      return null;
    }
  }
}

final jobSheetFormControllerProvider =
    NotifierProvider.family<
        JobSheetFormController,
        JobSheetFormState,
        String
    >(JobSheetFormController.new);