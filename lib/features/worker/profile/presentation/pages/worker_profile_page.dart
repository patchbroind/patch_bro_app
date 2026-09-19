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
  final _experienceController =
      TextEditingController();

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
          .read(
            workerProfileControllerProvider.notifier,
          )
          .loadProfile();
    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _populateProfile(
    BuildContext context,
  ) {
    final profile = ref
        .read(workerProfileControllerProvider)
        .profile;

    if (profile == null) {
      return;
    }

    if (_experienceController.text.isEmpty) {
      _profession = _professions.contains(
        profile.profession,
      )
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

      _availableToday =
          profile.availableToday;

      _availableTomorrow =
          profile.availableTomorrow;
    }
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
        .read(
          workerProfileControllerProvider.notifier,
        )
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
      _populateProfile(context);
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
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProfession(context),
              const SizedBox(height: 24),
              _buildSkills(context),
              const SizedBox(height: 24),
              AppTextField(
                controller: _experienceController,
                hintText: 'Years of experience',
                icon: Icons.work_history_outlined,
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.next,
                validator: Validators.required,
              ),
              const SizedBox(height: 24),
              _buildAbout(context),
              const SizedBox(height: 24),
              _buildAvailability(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.workerLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.workerPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handyman_outlined,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isSetup
                      ? 'Build your professional profile'
                      : 'Your professional profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tell employers what you do and when you are available.',
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
        ],
      ),
    );
  }

  Widget _buildProfession(
    BuildContext context,
  ) {
    return _Section(
      title: 'Profession',
      child: DropdownButtonFormField<String>(
        value: _profession,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.construction_outlined,
            color: AppColors.workerPrimary,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
        items: _professions
            .map(
              (profession) =>
                  DropdownMenuItem<String>(
                value: profession,
                child: Text(profession),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _profession = value;
          });
        },
      ),
    );
  }

  Widget _buildSkills(
    BuildContext context,
  ) {
    return _Section(
      title: 'Skills',
      subtitle:
          'Select the services you can provide.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _skills.map((skill) {
          final selected =
              _selectedSkills.contains(skill);

          return FilterChip(
            label: Text(skill),
            selected: selected,
            selectedColor:
                AppColors.workerLight,
            checkmarkColor:
                AppColors.workerPrimary,
            side: BorderSide(
              color: selected
                  ? AppColors.workerPrimary
                  : AppColors.border,
            ),
            onSelected: (value) {
              setState(() {
                if (value) {
                  _selectedSkills.add(skill);
                } else {
                  _selectedSkills.remove(skill);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAbout(
    BuildContext context,
  ) {
    return _Section(
      title: 'About you',
      subtitle:
          'Briefly describe your experience and services.',
      child: TextFormField(
        controller: _aboutController,
        minLines: 4,
        maxLines: 6,
        maxLength: 500,
        validator: Validators.required,
        decoration: InputDecoration(
          hintText:
              'Tell employers about your work experience...',
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailability(
    BuildContext context,
  ) {
    return _Section(
      title: 'Availability',
      subtitle:
          'Choose the days you normally accept jobs.',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _days.map((day) {
              final selected =
                  _selectedDays.contains(day);

              return FilterChip(
                label: Text(day),
                selected: selected,
                selectedColor:
                    AppColors.workerLight,
                checkmarkColor:
                    AppColors.workerPrimary,
                side: BorderSide(
                  color: selected
                      ? AppColors.workerPrimary
                      : AppColors.border,
                ),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title:
                const Text('Available today'),
            value: _availableToday,
            activeColor:
                AppColors.workerPrimary,
            onChanged: (value) {
              setState(() {
                _availableToday = value;
              });
            },
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title:
                const Text('Available tomorrow'),
            value: _availableTomorrow,
            activeColor:
                AppColors.workerPrimary,
            onChanged: (value) {
              setState(() {
                _availableTomorrow = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color:
                      AppColors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}