import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_job_entity.dart';
import '../widgets/employer_job_audio_player.dart';

class EmployerJobDetailsPage extends StatelessWidget {
  const EmployerJobDetailsPage({
    super.key,
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= 700
            ? 28.0
            : 16.0;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _JobHeader(job: job),
                  const SizedBox(height: 16),
                  _ScheduleCard(job: job),
                  const SizedBox(height: 16),
                  _LocationCard(job: job),
                  const SizedBox(height: 16),
                  if (job.hasDescription) ...[
                    _DescriptionCard(
                      description:
                          job.description,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (job.hasVoiceDescription) ...[
                    _VoiceDescriptionCard(
                      audioUrl:
                          job.audioUrl!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (job.hasImage) ...[
                    _ImagesCard(
                      imageUrl:
                          job.imageUrl!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _JobInformationCard(
                    job: job,
                  ),
                  const SizedBox(height: 24),
                  _ActionButtons(job: job),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JobHeader extends StatelessWidget {
  const _JobHeader({
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        switch (job.status) {
      EmployerJobStatus.active =>
        AppColors.info,
      EmployerJobStatus.completed =>
        AppColors.success,
      EmployerJobStatus.cancelled =>
        AppColors.textSecondary,
    };

    return _CardContainer(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.category,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                        fontWeight:
                            FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.skill,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusBadge(
            label: job.statusLabel,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialLocalizations.of(
      context,
    );

    final date =
        localizations.formatMediumDate(
      job.date,
    );

    final time =
        localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(
        job.time,
      ),
    );

    return _SectionCard(
      title: 'Schedule',
      icon: Icons.calendar_month_outlined,
      child: Row(
        children: [
          Expanded(
            child: _InfoTile(
              icon:
                  Icons.calendar_today_outlined,
              label: 'Date',
              value: date,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _InfoTile(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: time,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Job Location',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            job.locationAddress.isEmpty
                ? 'Location not available'
                : job.locationAddress,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textPrimary,
                  fontWeight:
                      FontWeight.w600,
                ),
          ),
          if (job.hasLocation) ...[
            const SizedBox(height: 14),
            _LocationMap(
              latitude: job.latitude!,
              longitude: job.longitude!,
            ),
            const SizedBox(height: 8),
            Text(
              '${job.latitude!.toStringAsFixed(6)}, '
              '${job.longitude!.toStringAsFixed(6)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color:
                        AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationMap extends StatelessWidget {
  const _LocationMap({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(
      latitude,
      longitude,
    );

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(14),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(
            target: position,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId:
                  const MarkerId(
                'job_location',
              ),
              position: position,
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        description,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(
              color:
                  AppColors.textSecondary,
              height: 1.55,
            ),
      ),
    );
  }
}

class _VoiceDescriptionCard
    extends StatelessWidget {
  const _VoiceDescriptionCard({
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Voice Description',
      icon: Icons.mic_none_rounded,
      child: EmployerJobAudioPlayer(
        audioUrl: audioUrl,
      ),
    );
  }
}

class _ImagesCard extends StatelessWidget {
  const _ImagesCard({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Job Image',
      icon: Icons.image_outlined,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder:
                (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress ==
                  null) {
                return child;
              }

              return const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.employerPrimary,
                ),
              );
            },
            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return const _ImageError();
            },
          ),
        ),
      ),
    );
  }
}

class _ImageError
    extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          AppColors.imagePlaceholder,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color:
              AppColors.imagePlaceholderIcon,
        ),
      ),
    );
  }
}

class _JobInformationCard
    extends StatelessWidget {
  const _JobInformationCard({
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialLocalizations.of(
      context,
    );

    return _SectionCard(
      title: 'Job Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _DetailRow(
            label: 'Job ID',
            value: job.id,
            selectable: true,
          ),
          const _DetailDivider(),
          _DetailRow(
            label: 'Status',
            value: job.statusLabel,
          ),
          const _DetailDivider(),
          _DetailRow(
            label: 'Category',
            value: job.category,
          ),
          const _DetailDivider(),
          _DetailRow(
            label: 'Skill',
            value: job.skill,
          ),
          const _DetailDivider(),
          _DetailRow(
            label: 'Created On',
            value: _formatDateTime(
              context,
              job.createdAt,
              localizations,
            ),
          ),
          const _DetailDivider(),
          _DetailRow(
            label: 'Last Updated',
            value: _formatDateTime(
              context,
              job.updatedAt,
              localizations,
            ),
          ),
          if (job.hasLocation) ...[
            const _DetailDivider(),
            _DetailRow(
              label: 'Coordinates',
              value:
                  '${job.latitude!.toStringAsFixed(6)}, '
                  '${job.longitude!.toStringAsFixed(6)}',
              selectable: true,
            ),
          ],
          const _DetailDivider(),
          _DetailRow(
            label: 'Voice Description',
            value:
                job.hasVoiceDescription
                    ? 'Available'
                    : 'Not added',
          ),
        ],
      ),
    );
  }

  String _formatDateTime(
    BuildContext context,
    DateTime value,
    MaterialLocalizations localizations,
  ) {
    final date =
        localizations.formatMediumDate(
      value,
    );

    final time =
        localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
    );

    return '$date • $time';
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Edit Job will be implemented
              // in the job editing feature.
            },
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text('Edit Job'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  AppColors.employerPrimary,
              side: const BorderSide(
                color:
                    AppColors.employerPrimary,
              ),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Find Workers will be implemented
              // in the worker matching feature.
            },
            icon: const Icon(
              Icons.people_outline,
            ),
            label:
                const Text('Invite Workers'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.employerPrimary,
              foregroundColor:
                  AppColors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    AppColors.employerPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color:
                          AppColors.textPrimary,
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            AppColors.imagePlaceholder,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                AppColors.employerPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      textAlign: TextAlign.right,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(
            color:
                AppColors.textPrimary,
            fontWeight:
                FontWeight.w600,
          ),
    );

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textSecondary,
                ),
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: selectable
              ? SelectableText(
                  value,
                  textAlign:
                      TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                )
              : valueWidget,
        ),
      ],
    );
  }
}

class _DetailDivider
    extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Divider(
        height: 1,
        color: AppColors.divider,
      ),
    );
  }
}

class _CardContainer
    extends StatelessWidget {
  const _CardContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}