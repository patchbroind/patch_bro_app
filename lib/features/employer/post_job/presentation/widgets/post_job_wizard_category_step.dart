import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';
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
    final names = categories
        .where((item) => item.isActive)
        .map((item) => item.name)
        .toList();
    final selected = names.contains(selectedCategory) ? selectedCategory : null;

    // Keep the same ValueNotifier synchronization as the original step.
    if (categoryValueNotifier.value != selected) {
      categoryValueNotifier.value = selected;
    }

    return PostJobSection(
      title: 'Category and required skill',
      subtitle: 'Choose the work type and the primary skill you need.',
      child: Column(
        children: [
          DropdownButtonFormField2<String>(
            valueListenable: categoryValueNotifier,
            isExpanded: true,
            decoration: const InputDecoration(
              hintText: 'Select job category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: names
                .map((name) => DropdownItem<String>(
                      value: name,
                      child: Text(name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: skillController,
            hintText: 'Required skill',
            icon: Icons.handyman_outlined,
            textInputAction: TextInputAction.next,
            onChanged: onSkillChanged,
          ),
          const SizedBox(height: 10),
          Text(
            'Skills are stored as one required-skill value by the current job API.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
