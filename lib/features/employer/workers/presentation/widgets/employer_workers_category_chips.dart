import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerWorkersCategoryChips extends StatelessWidget {
  const EmployerWorkersCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const categories = [
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.employerPrimary
                    : const Color(0xFFF5F7F8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
