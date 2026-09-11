import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/home/presentation/widgets/employer_category_card.dart';

import 'employer_section_header.dart';

class EmployerCategoriesSection extends StatelessWidget {
  const EmployerCategoriesSection({
    super.key,
    required this.searchQuery,
    required this.onCategoryTap,
    required this.onViewAll,
  });

  final String searchQuery;
  final ValueChanged<String> onCategoryTap;
  final VoidCallback onViewAll;

  static const categories = [
    (title: 'Cleaning', icon: Icons.cleaning_services_outlined),
    (title: 'Electrical', icon: Icons.electric_bolt_outlined),
    (title: 'Handyperson', icon: Icons.build_outlined),
    (title: 'HVAC', icon: Icons.ac_unit_outlined),
    (title: 'Plumbing', icon: Icons.plumbing_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();

    final filtered = query.isEmpty
        ? categories
        : categories
              .where((category) => category.title.toLowerCase().contains(query))
              .toList();

    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        EmployerSectionHeader(title: 'Categories', onViewAll: onViewAll),

        const SizedBox(height: 14),

        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = filtered[index];

              return EmployerCategoryCard(
                title: category.title,
                icon: category.icon,
                onTap: () {
                  onCategoryTap(category.title);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
