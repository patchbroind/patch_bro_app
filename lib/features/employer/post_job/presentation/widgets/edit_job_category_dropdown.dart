import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/home/domain/entities/category_entity.dart';

class EditJobCategoryDropdown extends StatelessWidget {
  const EditJobCategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.valueNotifier,
    required this.onChanged,
  });

  final List<CategoryEntity> categories;
  final String selectedCategory;
  final ValueNotifier<String?> valueNotifier;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final activeCategories = categories
        .where((category) => category.isActive)
        .toList();

    final activeNames = activeCategories
        .map((category) => category.name)
        .toSet();

    final keepLegacyValue =
        selectedCategory.trim().isNotEmpty &&
        !activeNames.contains(selectedCategory);

    final dropdownNames = <String>[
      if (keepLegacyValue) selectedCategory,
      ...activeCategories.map((category) => category.name),
    ];

    return DropdownButtonFormField2<String>(
      valueListenable: valueNotifier,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Enter job category',
        prefixIcon: Icon(
          Icons.category_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
      ),
      items: dropdownNames.toSet().map((name) {
        return DropdownItem<String>(value: name, child: Text(name));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select a category.';
        }
        return null;
      },
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
    );
  }
}
