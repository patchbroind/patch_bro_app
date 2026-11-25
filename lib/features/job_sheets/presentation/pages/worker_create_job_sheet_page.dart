
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/job_sheets/presentation/controllers/job_sheet_form_state.dart';

import '../controllers/job_sheet_form_controller.dart';

class WorkerCreateJobSheetPage extends ConsumerStatefulWidget {
  const WorkerCreateJobSheetPage({
    super.key,
    required this.jobId,
  });

  final String jobId;

  @override
  ConsumerState<WorkerCreateJobSheetPage> createState() =>
      _WorkerCreateJobSheetPageState();
}

class _WorkerCreateJobSheetPageState
    extends ConsumerState<WorkerCreateJobSheetPage> {
  final _formKey = GlobalKey<FormState>();

  final _summaryController = TextEditingController();
  final _materialsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    _materialsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = jobSheetFormControllerProvider(widget.jobId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      backgroundColor: WorkerColors.homeBackground,
      appBar: AppBar(
        title: const Text('Create Job Sheet'),
        backgroundColor: WorkerColors.homeBackground,
        foregroundColor: WorkerColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      'Work Summary',
                      'Describe the work completed.',
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _summaryController,
                      maxLines: 5,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'Describe the work you completed...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 5) {
                          return 'Please enter at least 5 characters.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle(
                      'Materials Used',
                      'Optional',
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _materialsController,
                      maxLines: 3,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'List materials, parts or tools used...',
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle(
                      'Additional Notes',
                      'Optional',
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'Any additional information...',
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle(
                      'Work Photos',
                      '${state.imagePaths.length}/5',
                    ),
                    const SizedBox(height: 10),

                    _buildImages(state, controller),

                    const SizedBox(height: 24),

                    _sectionTitle(
                      'Voice Recording',
                      'Optional',
                    ),
                    const SizedBox(height: 10),

                    _buildAudio(state, controller),

                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _errorBox(state.errorMessage!),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => _submit(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WorkerColors.homePrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Job Sheet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Once submitted, this Job Sheet will be visible '
                      'to both you and the employer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WorkerColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImages(
    JobSheetFormState state,
    JobSheetFormController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.imagePaths.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.imagePaths.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(state.imagePaths[index]),
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: state.imagePaths.length >= 5
              ? null
              : controller.pickImages,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(
            state.imagePaths.length >= 5
                ? 'Maximum photos selected'
                : 'Add Photos',
          ),
        ),
      ],
    );
  }

  Widget _buildAudio(
    JobSheetFormState state,
    JobSheetFormController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        border: Border.all(color: WorkerColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isRecording) ...[
            const Row(
              children: [
                Icon(Icons.mic, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Recording in progress...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else if (state.audioPath != null) ...[
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Voice recording attached',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              File(state.audioPath!).path.split('/').last,
              style: const TextStyle(fontSize: 12),
            ),
            TextButton.icon(
              onPressed: controller.removeAudio,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Recording'),
            ),
          ] else ...[
            const Text(
              'You can record a voice explanation of the completed work.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.startRecording,
                icon: const Icon(Icons.mic_none),
                label: const Text('Start Recording'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: WorkerColors.textSecondary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: WorkerColors.surface,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: WorkerColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: WorkerColors.border),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WorkerColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: WorkerColors.error,
        ),
      ),
    );
  }

  Future<void> _submit(JobSheetFormController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await controller.submit(
      workSummary: _summaryController.text,
      additionalNotes: _notesController.text,
      materialsUsed: _materialsController.text,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job Sheet submitted successfully!'),
        ),
      );

      Navigator.of(context).pop(result);
    }
  }
}