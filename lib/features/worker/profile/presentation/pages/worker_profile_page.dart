import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/validators/validators.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';

import '../providers/worker_profile_providers.dart';
import '../widgets/worker_profile_about.dart';
import '../widgets/worker_profile_availability.dart';
import '../widgets/worker_profile_header.dart';
import '../widgets/worker_profile_profession.dart';
import '../widgets/worker_profile_skills.dart';

class WorkerProfilePage extends ConsumerStatefulWidget {
  const WorkerProfilePage({
    super.key,
    this.isSetup = false,
  });

  final bool isSetup;

  @override
  ConsumerState<WorkerProfilePage> createState() =>
      _WorkerProfilePageState();
}

class _WorkerProfilePageState
    extends ConsumerState<WorkerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _aboutController = TextEditingController();
  final _experienceController = TextEditingController();

  static const _professions = [
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'AC Technician',
    'Mason',
    'Welder',
    'Tile Worker',
    'Gardener',
    'Cleaner',
    'Mechanic',
    'Other',
  ];

  static const _skills = [
    'Pipe Repair',
    'Bathroom',
    'Water Tank',
    'Wiring',
    'Fan Installation',
    'Switch Repair',
    'Furniture',
    'Wood Work',
    'Door Repair',
    'Interior Painting',
    'Exterior Painting',
    'Wall Finishing',
    'AC Repair',
    'AC Installation',
    'General Maintenance',
  ];

  static const _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String _profession = _professions.first;

  final Set<String> _selectedSkills = {};
  final Set<String> _selectedDays = {};

  bool _availableToday = false;
  bool _availableTomorrow = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(workerProfileControllerProvider.notifier)
          .loadProfile();
    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _populateProfile() {
    final profile = ref
        .read(workerProfileControllerProvider)
        .profile;

    if (profile == null) {
      return;
    }

    if (_experienceController.text.isNotEmpty) {
      return;
    }

    _profession = _professions.contains(profile.profession)
        ? profile.profession
        : 'Other';

    _selectedSkills
      ..clear()
      ..addAll(profile.skills);

    _selectedDays
      ..clear()
      ..addAll(profile.availabilityDays);

    _aboutController.text = profile.about;

    _experienceController.text =
        profile.experienceYears.toString();

    _availableToday = profile.availableToday;
    _availableTomorrow = profile.availableTomorrow;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSkills.isEmpty) {
      AppSnackbar.error(
        context,
        'Please select at least one skill.',
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      AppSnackbar.error(
        context,
        'Please select your available days.',
      );
      return;
    }

    final experience = int.tryParse(
      _experienceController.text.trim(),
    );

    if (experience == null || experience < 0) {
      AppSnackbar.error(
        context,
        'Please enter a valid experience.',
      );
      return;
    }

    final success = await ref
        .read(workerProfileControllerProvider.notifier)
        .saveProfile(
          profession: _profession,
          skills: _selectedSkills.toList(),
          about: _aboutController.text.trim(),
          experienceYears: experience,
          availabilityDays: _selectedDays.toList(),
          availableToday: _availableToday,
          availableTomorrow: _availableTomorrow,
        );

    if (!mounted) {
      return;
    }

    if (!success) {
      final error = ref
          .read(workerProfileControllerProvider)
          .errorMessage;

      AppSnackbar.error(
        context,
        error ?? 'Unable to save worker profile.',
      );

      return;
    }

    if (widget.isSetup) {
      context.goNamed(RouteNames.workerHome);
    } else {
      AppSnackbar.success(
        context,
        'Worker profile updated.',
      );
    }
  }

  void _onProfessionChanged(String value) {
    setState(() {
      _profession = value;
    });
  }

  void _onSkillChanged(
    String skill,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedSkills.add(skill);
      } else {
        _selectedSkills.remove(skill);
      }
    });
  }

  void _onDayChanged(
    String day,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedDays.add(day);
      } else {
        _selectedDays.remove(day);
      }
    });
  }

  void _onAvailableTodayChanged(bool value) {
    setState(() {
      _availableToday = value;
    });
  }

  void _onAvailableTomorrowChanged(bool value) {
    setState(() {
      _availableTomorrow = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      workerProfileControllerProvider,
    );

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.workerPrimary,
          ),
        ),
      );
    }

    if (state.hasProfile) {
      _populateProfile();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isSetup
              ? 'Set Up Worker Profile'
              : 'Worker Profile',
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              32,
            ),
            children: [
              WorkerProfileHeader(
                isSetup: widget.isSetup,
              ),
              const SizedBox(height: 24),

              WorkerProfileProfession(
                profession: _profession,
                professions: _professions,
                onChanged: _onProfessionChanged,
              ),
              const SizedBox(height: 24),

              WorkerProfileSkills(
                skills: _skills,
                selectedSkills: _selectedSkills,
                onSkillChanged: _onSkillChanged,
              ),
              const SizedBox(height: 24),

              AppTextField(
                controller: _experienceController,
                hintText: 'Years of experience',
                icon: Icons.work_history_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: Validators.required,
              ),
              const SizedBox(height: 24),

              WorkerProfileAbout(
                controller: _aboutController,
              ),
              const SizedBox(height: 24),

              WorkerProfileAvailability(
                days: _days,
                selectedDays: _selectedDays,
                availableToday: _availableToday,
                availableTomorrow: _availableTomorrow,
                onDayChanged: _onDayChanged,
                onAvailableTodayChanged:
                    _onAvailableTodayChanged,
                onAvailableTomorrowChanged:
                    _onAvailableTomorrowChanged,
              ),
              const SizedBox(height: 32),

              AppPrimaryButton(
                label: widget.isSetup
                    ? 'Complete Profile'
                    : 'Save Changes',
                isLoading: state.isSaving,
                backgroundColor:
                    AppColors.workerPrimary,
                onPressed: state.isSaving
                    ? null
                    : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}