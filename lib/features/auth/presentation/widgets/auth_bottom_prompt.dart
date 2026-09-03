import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class AuthBottomPrompt extends StatelessWidget {
  const AuthBottomPrompt({
    super.key,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(message, style: const TextStyle(color: AppColors.textTertiary, fontSize: 16)),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
