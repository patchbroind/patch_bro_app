import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';

class PostJobCategorySkillFields extends StatelessWidget {
  const PostJobCategorySkillFields({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.categoryValueNotifier,
    required this.skillController,
    required this.onCategoryChanged,
    required this.onSkillChanged,
    this.categoryHintText = 'Select job category',
    this.showSkillHint = false,
    this.validateCategory = false,
    this.retainLegacyCategory = true,
  });

  final List<CategoryEntity> categories;
  final String selectedCategory;
  final ValueNotifier<String?> categoryValueNotifier;
  final TextEditingController skillController;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSkillChanged;
  final String categoryHintText;
  final bool showSkillHint;
  final bool validateCategory;
  final bool retainLegacyCategory;

  @override
  Widget build(BuildContext context) {
    final categoryNames = categories
        .where((category) => category.isActive)
        .map((category) => category.name)
        .toList(growable: false);
    final categoryNameSet = categoryNames.toSet();
    final includeLegacyCategory =
        retainLegacyCategory &&
        selectedCategory.trim().isNotEmpty &&
        !categoryNameSet.contains(selectedCategory);
    final dropdownNames = <String>{
      if (includeLegacyCategory) selectedCategory,
      ...categoryNames,
    }.toList(growable: false);
    final selectedValue = dropdownNames.contains(selectedCategory)
        ? selectedCategory
        : null;

    if (categoryValueNotifier.value != selectedValue) {
      categoryValueNotifier.value = selectedValue;
    }

    return Column(
      children: [
        DropdownButtonFormField2<String>(
          valueListenable: categoryValueNotifier,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: categoryHintText,
            prefixIcon: Icon(
              Icons.category_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          items: dropdownNames
              .map(
                (name) => DropdownItem<String>(value: name, child: Text(name)),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) onCategoryChanged(value);
          },
          validator: validateCategory
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Please select a category.'
                    : null
              : null,
          dropdownStyleData: DropdownStyleData(
            width: MediaQuery.sizeOf(context).width - 34,
            offset: const Offset(-30, 0),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: skillController,
          hintText: 'Required skill',
          icon: Icons.handyman_outlined,
          textInputAction: TextInputAction.next,
          onChanged: onSkillChanged,
        ),
        if (showSkillHint) ...[
          const SizedBox(height: 10),
          Text(
            'Skills are stored as one required-skill value by the current job API.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
