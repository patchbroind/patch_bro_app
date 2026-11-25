import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/job_sheet_entity.dart';
import '../providers/job_sheet_providers.dart';

class JobSheetViewPage extends ConsumerWidget {
  const JobSheetViewPage({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetAsync = ref.watch(jobSheetProvider(jobId));

    return Scaffold(
      backgroundColor: WorkerColors.homeBackground,
      appBar: AppBar(
        title: const Text('Job Sheet'),
        backgroundColor: WorkerColors.homeBackground,
        foregroundColor: WorkerColors.textPrimary,
        elevation: 0,
      ),
      body: sheetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load Job Sheet.\n$error'),
          ),
        ),
        data: (sheet) {
          if (sheet == null) {
            return const Center(child: Text('Job Sheet has not been submitted yet.'));
          }

          return _JobSheetContent(sheet: sheet);
        },
      ),
    );
  }
}

class _JobSheetContent extends StatelessWidget {
  const _JobSheetContent({required this.sheet});

  final JobSheetEntity sheet;

  @override
  Widget build(BuildContext context) {
    final originalJob = sheet.originalJob;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: WorkerColors.success),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Job Sheet Submitted',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Submitted by ${sheet.workerName}'),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(sheet.submittedAt),
                      style: const TextStyle(color: WorkerColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _section(
                title: 'Work Summary',
                child: Text(sheet.workSummary, style: const TextStyle(fontSize: 15, height: 1.6)),
              ),

              if (_hasText(sheet.materialsUsed)) ...[
                const SizedBox(height: 16),
                _section(title: 'Materials Used', child: Text(sheet.materialsUsed!)),
              ],

              if (_hasText(sheet.additionalNotes)) ...[
                const SizedBox(height: 16),
                _section(title: 'Additional Notes', child: Text(sheet.additionalNotes!)),
              ],

              if (sheet.workerImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                _section(title: 'Work Photos', child: _imageGallery(sheet.workerImages)),
              ],

              if (sheet.workerAudio != null) ...[
                const SizedBox(height: 16),
                _section(
                  title: 'Voice Recording',
                  child: OutlinedButton.icon(
                    onPressed: () => _openUrl(sheet.workerAudio!.url),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Open Voice Recording'),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              _section(
                title: 'Original Job Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detail('Category', originalJob['category']),
                    _detail('Skill', originalJob['skill']),
                    _detail('Date', originalJob['scheduled_date']),
                    _detail('Time', originalJob['scheduled_time']),
                    _detail('Location', originalJob['location_address']),
                    if (_hasText(originalJob['description']))
                      _detail('Description', originalJob['description']),
                  ],
                ),
              ),

              if (sheet.originalMedia.isNotEmpty) ...[
                const SizedBox(height: 16),
                _section(
                  title: 'Original Job Attachments',
                  child: _imageGallery(
                    sheet.originalMedia.where((media) => media.mediaType == 'image').toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageGallery(List<JobSheetMediaEntity> images) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: images.map((media) {
        return GestureDetector(
          onTap: () => _openImage(media.url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              media.url,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 140,
                height: 140,
                color: WorkerColors.imagePlaceholder,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkerColors.border),
      ),
      child: child,
    );
  }

  Widget _detail(String label, dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: WorkerColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  bool _hasText(dynamic value) {
    return value != null && value.toString().trim().isNotEmpty;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openImage(String url) async {
    await _openUrl(url);
  }
}
