import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> pickImages() async {
    if (state.images.length >= 2) {
      return;
    }

    final remaining = 2 - state.images.length;

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

  Future<void> removeImage(int index) async {
    if (index < 0 || index >= state.images.length) {
      return;
    }

    final updatedImages = [...state.images];
    updatedImages.removeAt(index);

    state = state.copyWith(images: updatedImages, status: PostJobStatus.initial, clearError: true);
  }

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
    } catch (e) {
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
        status: PostJobStatus.initial,
        clearError: true,
      );
    } catch (e) {
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

  void removeVoiceRecording() {
    state = state.copyWith(
      clearVoiceRecording: true,
      recordingDuration: Duration.zero,
      status: PostJobStatus.initial,
      clearError: true,
    );
  }

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

    if (state.description.trim().isEmpty && state.voiceRecording == null) {
      return 'Please add a text or voice description.';
    }

    return null;
  }

  Future<bool> submitJob() async {
    final validationError = _validate();

    if (validationError != null) {
      state = state.copyWith(status: PostJobStatus.failure, errorMessage: validationError);
      return false;
    }

    state = state.copyWith(status: PostJobStatus.submitting, clearError: true);

    try {
      await _repository.createJob(
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

      return true;
    } catch (e) {
      state = state.copyWith(status: PostJobStatus.failure, errorMessage: e.toString());

      return false;
    }
  }

  void reset() {
    state = const PostJobState();
  }
}
