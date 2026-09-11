import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';
import 'package:patch_bro/features/profile/presentation/pages/location_picker_page.dart';

import '../providers/employer_home_provider.dart';
import '../widgets/employer_categories_section.dart';
import '../widgets/employer_home_carousel.dart';
import '../widgets/employer_home_header.dart';
import '../widgets/employer_popular_projects_section.dart';
import '../widgets/employer_search_bar.dart';
import '../widgets/employer_home_state_views.dart';

class EmployerHomePage extends ConsumerStatefulWidget {
  const EmployerHomePage({super.key});

  @override
  ConsumerState<EmployerHomePage> createState() => _EmployerHomePageState();
}

class _EmployerHomePageState extends ConsumerState<EmployerHomePage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  bool _locationPromptShown = false;
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationRequirement();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // LOCATION
  // ================================================================

  Future<void> _checkLocationRequirement() async {
    if (_locationPromptShown) {
      return;
    }

    try {
      final homeData = await ref.read(employerHomeProvider.future);

      if (!mounted) {
        return;
      }

      if (!homeData.hasLocation) {
        _locationPromptShown = true;

        await _showLocationRequiredDialog();
      }
    } catch (_) {
      // Don't show the location dialog if the
      // profile itself could not be loaded.
    }
  }

  Future<void> _showLocationRequiredDialog() async {
    final shouldChooseLocation = await AppDialog.confirm(
      context,
      title: 'Choose your location',
      message:
          'Set your location to find nearby workers and get better service recommendations.',
      confirmLabel: 'Choose Location',
      cancelLabel: 'Skip for now',
    );

    if (shouldChooseLocation == true && mounted) {
      await _openLocationPicker();
    }
  }

  Future<void> _openLocationPicker() async {
    if (_isUpdatingLocation) {
      return;
    }

    final currentLocation = ref.read(employerHomeProvider).value?.location;

    final result = await Navigator.of(context).push<ProfileLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialLocation: currentLocation),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _isUpdatingLocation = true;
    });

    try {
      await ref
          .read(employerHomeRepositoryProvider)
          .updateLocation(
            latitude: result.latitude,
            longitude: result.longitude,
            address: result.address,
          );

      ref.invalidate(employerHomeProvider);

      await ref.read(employerHomeProvider.future);

      if (!mounted) {
        return;
      }

      AppSnackbar.success(context, 'Location updated successfully.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to update location. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  // ================================================================
  // SEARCH
  // ================================================================

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  // ================================================================
  // ACTIONS
  // ================================================================

  void _onCategoryTap(String category) {
    AppSnackbar.success(context, 'Selected $category');
  }

  void _onProjectTap(String project) {
    AppSnackbar.success(context, 'Selected $project');
  }

  void _onCarouselTap(int index) {
    AppSnackbar.success(context, 'Opening featured service');
  }

  void _onViewAllCategories() {
    AppSnackbar.success(context, 'Categories');
  }

  void _onViewAllProjects() {
    AppSnackbar.success(context, 'Popular projects');
  }

  void _onNotificationTap() {
    AppSnackbar.success(context, 'Notifications');
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(employerHomeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: homeAsync.when(
          loading: () {
            return const EmployerHomeLoading();
          },
          error: (error, stackTrace) {
            return EmployerHomeError(
              onRetry: () {
                ref.invalidate(employerHomeProvider);
              },
            );
          },
          data: (homeData) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(employerHomeProvider);

                await ref.read(employerHomeProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // HEADER
                    // ------------------------------------------------

                    EmployerHomeHeader(
                      data: homeData,
                      onLocationTap: _openLocationPicker,
                      onNotificationTap: _onNotificationTap,
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // SEARCH
                    // ------------------------------------------------
                    EmployerSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                    ),

                    const SizedBox(height: 28),

                    // ------------------------------------------------
                    // CATEGORIES
                    // ------------------------------------------------
                    EmployerCategoriesSection(
                      searchQuery: _searchQuery,
                      onCategoryTap: _onCategoryTap,
                      onViewAll: _onViewAllCategories,
                    ),

                    const SizedBox(height: 28),

                    // ------------------------------------------------
                    // POPULAR PROJECTS
                    // ------------------------------------------------
                    EmployerPopularProjectsSection(
                      searchQuery: _searchQuery,
                      onProjectTap: _onProjectTap,
                      onViewAll: _onViewAllProjects,
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // FEATURED CAROUSEL
                    // ------------------------------------------------
                    EmployerHomeCarousel(onTap: _onCarouselTap),

                    const SizedBox(height: 4),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
