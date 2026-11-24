import 'package:material_ui/material_ui.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerHomeLoading extends StatelessWidget {
  const EmployerHomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.employerPrimary),
    );
  }
}

