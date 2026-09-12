import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({super.key, required this.size, required this.name, required this.imageUrl});

  final double size;
  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isEmpty
        ? 'U'
        : name.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _FallbackAvatar(
                  letter: firstLetter,
                  color: AppColors.employerPrimary,
                );
              },
            )
          : _FallbackAvatar(
              letter: firstLetter,
              color: AppColors.employerPrimary,
            ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}