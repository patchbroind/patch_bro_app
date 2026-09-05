import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/location_service.dart';
import '../../domain/entities/profile_location.dart';
import '../../../../core/location/location_permission_service.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLocation,
  });

  final ProfileLocation? initialLocation;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;

  ProfileLocation? _selectedLocation;

  bool _isGettingCurrentLocation = false;
  bool _isLoadingAddress = false;

  // Default location: Kerala.
  static const LatLng _defaultLocation = LatLng(
    10.8505,
    76.2711,
  );

  @override
  void initState() {
    super.initState();

    _selectedLocation = widget.initialLocation;
  }

  LatLng get _initialPosition {
    final location = widget.initialLocation;

    if (location != null) {
      return LatLng(
        location.latitude,
        location.longitude,
      );
    }

    return _defaultLocation;
  }

  Future<void> _useCurrentLocation() async {
    if (_isGettingCurrentLocation) {
      return;
    }

    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      final locationService = LocationService();

      final result = await locationService.getCurrentLocation();

      final location = ProfileLocation(
        latitude: result.latitude,
        longitude: result.longitude,
        address: result.address,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedLocation = location;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            result.latitude,
            result.longitude,
          ),
          16,
        ),
      );
    } on LocationServiceDisabledException catch (error) {
      _showError(error.toString());
    } on LocationPermissionDeniedException catch (error) {
      _showError(error.toString());
    } on LocationPermissionPermanentlyDeniedException catch (error) {
      _showError(error.toString());
    } catch (error) {
      _showError(
        'Unable to get your current location: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final locationService = LocationService();

      final address = await locationService.getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedLocation = ProfileLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedLocation = ProfileLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: 'Selected location',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _confirmLocation() {
    final location = _selectedLocation;

    if (location == null) {
      _showError(
        'Please select a location on the map.',
      );
      return;
    }

    Navigator.of(context).pop(location);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = _selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: widget.initialLocation == null ? 7 : 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId(
                        'selected_location',
                      ),
                      position: LatLng(
                        selectedLocation.latitude,
                        selectedLocation.longitude,
                      ),
                    ),
                  },
          ),

          // Current location button.
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _isGettingCurrentLocation
                    ? null
                    : _useCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isGettingCurrentLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                        ),
                ),
              ),
            ),
          ),

          // Selected location information.
          if (selectedLocation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _LocationConfirmationCard(
                location: selectedLocation,
                isLoadingAddress: _isLoadingAddress,
                onConfirm: _confirmLocation,
              ),
            ),

          // Instruction when no location has been selected.
          if (selectedLocation == null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Text(
                  'Tap anywhere on the map to select your location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _LocationConfirmationCard extends StatelessWidget {
  const _LocationConfirmationCard({
    required this.location,
    required this.isLoadingAddress,
    required this.onConfirm,
  });

  final ProfileLocation location;
  final bool isLoadingAddress;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 5),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Selected Location',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          isLoadingAddress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  location.address,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingAddress ? null : onConfirm,
              child: const Text(
                'Confirm Location',
              ),
            ),
          ),
        ],
      ),
    );
  }
}