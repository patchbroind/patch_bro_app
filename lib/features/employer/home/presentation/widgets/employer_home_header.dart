import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import '../../domain/entities/employer_home_entity.dart';

class EmployerHomeHeader extends StatelessWidget {
  const EmployerHomeHeader({
    super.key,
    required this.data,
    required this.onLocationTap,
    required this.onNotificationTap,
  });

  final EmployerHomeEntity data;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileAvatar(name: data.name, imageUrl: data.avatarUrl),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.employerPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              GestureDetector(
                onTap: onLocationTap,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.location?.address ?? 'Add location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: data.location == null
                              ? AppColors.employerPrimary
                              : AppColors.textSecondary,
                          fontWeight: data.location == null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.employerPrimary,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, required this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isEmpty
        ? 'U'
        : name.trim()[0].toUpperCase();

    return Container(
      width: 44,
      height: 44,
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
