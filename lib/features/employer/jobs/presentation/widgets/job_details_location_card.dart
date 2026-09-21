import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_section_card.dart';

class JobDetailsLocationCard extends StatelessWidget {
  const JobDetailsLocationCard({super.key, 
    required this.job,
  });

  final EmployerJobEntity job;

  @override
  Widget build(BuildContext context) {
    return JobDetailSectionCard(
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