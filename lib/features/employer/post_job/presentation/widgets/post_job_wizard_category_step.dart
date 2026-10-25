import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_category_skill_fields.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_section.dart';

class PostJobWizardCategoryStep extends StatelessWidget {
  const PostJobWizardCategoryStep({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.categoryValueNotifier,
    required this.skillController,
    required this.onCategoryChanged,
    required this.onSkillChanged,
  });

  final List<CategoryEntity> categories;
  final String selectedCategory;
  final ValueNotifier<String?> categoryValueNotifier;
  final TextEditingController skillController;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSkillChanged;

  @override
  Widget build(BuildContext context) {
    return PostJobSection(
      title: 'Category and required skill',
      subtitle: 'Choose the work type and the primary skill you need.',
      child: PostJobCategorySkillFields(
        categories: categories,
        selectedCategory: selectedCategory,
        categoryValueNotifier: categoryValueNotifier,
        skillController: skillController,
        onCategoryChanged: onCategoryChanged,
        onSkillChanged: onSkillChanged,
        showSkillHint: true,
        retainLegacyCategory: false,
      ),
    );
  }
}
