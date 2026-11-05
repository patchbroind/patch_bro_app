import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/profile_avatar_widget.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_icon_badge.dart';

class WorkerHomeHeaderSection extends StatelessWidget {
  const WorkerHomeHeaderSection({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.unreadCount,
  });

  final String name;
  final String? avatarUrl;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      decoration: const BoxDecoration(
        color: WorkerColors.homeHeaderBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -24,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: WorkerColors.surface.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: -12,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: WorkerColors.homePrimary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ProfileAvatarWidget(
                      size: 62,
                      name: name,
                      imageUrl: avatarUrl,
                      fallbackColor: WorkerColors.homePrimary,
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: WorkerColors.success,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: WorkerColors.surface, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: WorkerColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: WorkerColors.textPrimary,
                              fontSize: 26,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Have a great day! 👋',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WorkerColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    WorkerIconBadge(
                      icon: Icons.mail_outline_rounded,
                      badgeCount: 0,
                      color: WorkerColors.surface,
                    ),
                    const SizedBox(width: 10),
                    WorkerIconBadge(
                      icon: Icons.notifications_none_rounded,
                      badgeCount: unreadCount,
                      color: WorkerColors.surface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
