import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_wizard_location_option.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';

class PostJobWizardLocationStep extends StatelessWidget {
  const PostJobWizardLocationStep({
    super.key,
    required this.savedLocation,
    required this.selectedAddress,
    required this.latitude,
    required this.longitude,
    required this.onChooseLocation,
    required this.onUseCurrentLocation,
    required this.onSelectLocation,
  });

  final ProfileLocation? savedLocation;
  final String? selectedAddress;
  final double? latitude;
  final double? longitude;
  final VoidCallback onChooseLocation;
  final VoidCallback onUseCurrentLocation;
  final ValueChanged<ProfileLocation> onSelectLocation;

  @override
  Widget build(BuildContext context) {
    final hasSelectedLocation = selectedAddress?.trim().isNotEmpty == true;
    final isSavedSelected = savedLocation != null &&
        latitude == savedLocation!.latitude &&
        longitude == savedLocation!.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostJobSection(
          title: 'Your saved location',
          subtitle: savedLocation == null
              ? 'No saved profile location is available.'
              : 'Use your profile location or select another place.',
          child: savedLocation == null
              ? const Text(
                  'Choose a different location or use your current location.',
                )
              : PostJobWizardLocationOption(
                  icon: Icons.home_outlined,
                  title: savedLocation!.address,
                  subtitle: isSavedSelected
                      ? 'Selected for this job'
                      : 'Use this saved location',
                  selected: isSavedSelected,
                  onTap: () => onSelectLocation(savedLocation!),
                ),
        ),
        const SizedBox(height: 18),
        PostJobSection(
          title: 'Job location',
          subtitle: hasSelectedLocation
              ? 'Selected location is shown below.'
              : 'Select where the worker should arrive.',
          child: Column(
            children: [
              if (hasSelectedLocation) ...[
                PostJobWizardLocationOption(
                  icon: Icons.location_on_outlined,
                  title: selectedAddress!,
                  subtitle: 'Currently selected',
                  selected: true,
                  onTap: onChooseLocation,
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: onChooseLocation,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Choose a different location'),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onUseCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use current location'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
