import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class PostJobWorkerSearchbar extends StatelessWidget {
  const PostJobWorkerSearchbar({
    super.key,
    required this._searchController,
    required this._searchQuery,
  });

  final TextEditingController _searchController;
  final String _searchQuery;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search workers by name',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.employerPrimary),
        ),
      ),
    );
  }
}