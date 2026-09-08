import 'package:flutter/material.dart';

import '../../domain/entities/profile_location.dart';
import '../pages/location_picker_page.dart';
import 'selected_location_card.dart';

class ProfileLocationSection extends StatelessWidget {
  const ProfileLocationSection({
    super.key,
    required this.location,
    required this.onLocationSelected,
  });

  final ProfileLocation? location;
  final ValueChanged<ProfileLocation> onLocationSelected;

  Future<void> _openLocationPicker(
    BuildContext context,
  ) async {
    final result = await Navigator.of(context).push<ProfileLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLocation: location,
        ),
      ),
    );

    if (result != null) {
      onLocationSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Set your location to help Patch Bro provide nearby jobs and location-based services.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 14),

        if (location == null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openLocationPicker(context),
              icon: Icon(
                Icons.location_on_outlined,
                color: primaryColor,
              ),
              label: const Text(
                'Choose Your Location',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          SelectedLocationCard(
            location: location!,
            onChange: () => _openLocationPicker(context),
          ),
      ],
    );
  }
}