import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';

import '../controllers/employer_workers_state.dart';

class EmployerWorkersFilterSheet extends StatefulWidget {
  const EmployerWorkersFilterSheet({
    super.key,
    required this.initialFilters,
  });

  final EmployerWorkersFilters initialFilters;

  @override
  State<EmployerWorkersFilterSheet> createState() =>
      _EmployerWorkersFilterSheetState();
}

class _EmployerWorkersFilterSheetState
    extends State<EmployerWorkersFilterSheet> {
  late EmployerWorkersFilters _filters;

  final categories = const [
    'All',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'AC Technician',
    'Cleaner',
    'Mason',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilters(EmployerWorkersFilters value) {
    setState(() {
      _filters = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Category'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final selected =
                            _filters.category == category;

                        return _ChoiceChip(
                          label: category,
                          selected: selected,
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(category: category),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    _sectionTitle(context, 'Distance'),
                    const SizedBox(height: 2),
                    Text(
                      'Within ${_filters.distanceKm.round()} km',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Slider(
                      value: _filters.distanceKm,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      activeColor: AppColors.employerPrimary,
                      onChanged: (value) {
                        _updateFilters(
                          _filters.copyWith(distanceKm: value),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _smallLabel(context, '1 km'),
                        _smallLabel(context, '50 km'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle(context, 'Minimum Rating'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ChoiceChip(
                          label: 'Any',
                          selected: _filters.minimumRating == 0,
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(minimumRating: 0),
                            );
                          },
                        ),
                        _ChoiceChip(
                          label: '4.0+',
                          selected: _filters.minimumRating == 4,
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(minimumRating: 4),
                            );
                          },
                        ),
                        _ChoiceChip(
                          label: '4.5+',
                          selected: _filters.minimumRating == 4.5,
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(minimumRating: 4.5),
                            );
                          },
                        ),
                        _ChoiceChip(
                          label: '5.0',
                          selected: _filters.minimumRating == 5,
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(minimumRating: 5),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle(context, 'Availability'),
                    const SizedBox(height: 8),
                    _AvailabilityRadio(
                      label: 'Any time',
                      selected: _filters.availability == 'Any time',
                      onTap: () {
                        _updateFilters(
                          _filters.copyWith(
                            availability: 'Any time',
                          ),
                        );
                      },
                    ),
                    _AvailabilityRadio(
                      label: 'Available today',
                      selected:
                          _filters.availability == 'Available today',
                      onTap: () {
                        _updateFilters(
                          _filters.copyWith(
                            availability: 'Available today',
                          ),
                        );
                      },
                    ),
                    _AvailabilityRadio(
                      label: 'Available tomorrow',
                      selected:
                          _filters.availability == 'Available tomorrow',
                      onTap: () {
                        _updateFilters(
                          _filters.copyWith(
                            availability: 'Available tomorrow',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle(context, 'Experience'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ChoiceChip(
                          label: 'Any',
                          selected: _filters.experience == 'Any',
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(
                                experience: 'Any',
                              ),
                            );
                          },
                        ),
                        _ChoiceChip(
                          label: '1+ years',
                          selected: _filters.experience == '1+ years',
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(
                                experience: '1+ years',
                              ),
                            );
                          },
                        ),
                        _ChoiceChip(
                          label: '3+ years',
                          selected: _filters.experience == '3+ years',
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(
                                experience: '3+ years',
                              ),
                            );
                          },
                        ),
                        _ChoiceChip(
                          label: '5+ years',
                          selected: _filters.experience == '5+ years',
                          onTap: () {
                            _updateFilters(
                              _filters.copyWith(
                                experience: '5+ years',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Currently available'),
                      value: _filters.currentlyAvailableOnly,
                      activeColor: AppColors.employerPrimary,
                      onChanged: (value) {
                        _updateFilters(
                          _filters.copyWith(
                            currentlyAvailableOnly: value,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          const EmployerWorkersFilters(),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppPrimaryButton(
                      label: 'Apply Filters',
                      backgroundColor: AppColors.employerPrimary,
                      onPressed: () {
                        Navigator.pop(context, _filters);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
    );
  }

  Widget _smallLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.employerPrimary
              : const Color(0xFFF4F6F7),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    selected ? AppColors.white : AppColors.textPrimary,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _AvailabilityRadio extends StatelessWidget {
  const _AvailabilityRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? AppColors.employerPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}