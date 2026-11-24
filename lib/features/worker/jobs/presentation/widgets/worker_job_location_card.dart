
import 'package:material_ui/material_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/home/domain/entities/worker_home_job_entity.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';

class WorkerJobLocationCard extends StatelessWidget {
  const WorkerJobLocationCard({
    super.key,
    required this.job,
  });

  final WorkerHomeJobEntity job;

  Future<void> _openDirections(BuildContext context) async {
    if (!job.hasLocation) return;

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '${job.latitude},${job.longitude}',
        'travelmode': 'driving',
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Google Maps.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Google Maps.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkerJobDetailSection(
      title: 'Job Location',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.place_outlined,
                color: WorkerColors.homePrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.locationAddress.isNotEmpty
                      ? job.locationAddress
                      : 'Location not available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WorkerColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
          if (job.hasLocation) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openDirections(context),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                job.latitude!,
                                job.longitude!,
                              ),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('worker_job_location'),
                                position: LatLng(
                                  job.latitude!,
                                  job.longitude!,
                                ),
                              ),
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            mapToolbarEnabled: false,
                            compassEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: WorkerColors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: WorkerColors.cardShadow,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions,
                                size: 17,
                                color: WorkerColors.homePrimary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Get Directions',
                                style: TextStyle(
                                  color: WorkerColors.homePrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the map to open directions in Google Maps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WorkerColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}