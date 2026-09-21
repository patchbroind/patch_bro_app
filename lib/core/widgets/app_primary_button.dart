import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Icon? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(backgroundColor:backgroundColor ,),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
              )
            : Row(
              mainAxisAlignment: .center,
              spacing: 5,
              children: [
                ?leadingIcon,
                Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
      ),
    );
  }
}
