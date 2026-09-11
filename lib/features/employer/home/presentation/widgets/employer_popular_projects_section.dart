import 'package:flutter/material.dart';

import 'employer_project_card.dart';
import 'employer_section_header.dart';

class EmployerPopularProjectsSection extends StatelessWidget {
  const EmployerPopularProjectsSection({
    super.key,
    required this.searchQuery,
    required this.onProjectTap,
    required this.onViewAll,
  });

  final String searchQuery;
  final ValueChanged<String> onProjectTap;
  final VoidCallback onViewAll;

  static const projects = [
    (title: 'Cleaning', image: 'assets/images/employer/cleaning.png'),
    (title: 'Electrician', image: 'assets/images/employer/electrician.png'),
    (title: 'Plumbing', image: 'assets/images/employer/plumbing.png'),
    (title: 'Painting', image: 'assets/images/employer/painting.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();

    final filtered = query.isEmpty
        ? projects
        : projects
              .where((project) => project.title.toLowerCase().contains(query))
              .toList();

    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        EmployerSectionHeader(title: 'Popular project', onViewAll: onViewAll),

        const SizedBox(height: 12),

        SizedBox(
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final project = filtered[index];

              return EmployerProjectCard(
                title: project.title,
                imagePath: project.image,
                onTap: () {
                  onProjectTap(project.title);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
