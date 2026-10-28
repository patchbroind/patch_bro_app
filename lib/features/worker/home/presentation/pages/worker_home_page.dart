import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:patch_bro/features/profile/presentation/providers/profile_providers.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/promotional_ad_banner.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_elite_progress_banner.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_home_header_section.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_latest_invitation_section.dart';
import 'package:patch_bro/features/worker/home/presentation/widgets/worker_upcoming_work_section.dart';
import 'package:patch_bro/features/worker/invitations/presentation/providers/worker_invitations_providers.dart';
import 'package:patch_bro/features/worker/profile/presentation/providers/worker_profile_providers.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

import '../providers/worker_home_providers.dart';

class WorkerHomePage extends ConsumerStatefulWidget {
  const WorkerHomePage({super.key});

  @override
  ConsumerState<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends ConsumerState<WorkerHomePage> {
  String _displayName = 'Worker';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(workerHomeControllerProvider.notifier).load();
      ref.read(workerProfileControllerProvider.notifier).loadProfile();
      ref.read(workerInvitationsControllerProvider.notifier).initialize();
      ref.read(workerNotificationsControllerProvider.notifier).initialize();
      _loadBasicProfile();
    });
  }

  Future<void> _loadBasicProfile() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getCurrentProfile();
      if (!mounted) return;
      setState(() {
        _displayName = (profile?['name'] as String?)?.trim().isNotEmpty == true
            ? profile!['name'].toString()
            : 'Worker';
        _avatarUrl = profile?['avatar_url']?.toString();
      });
    } catch (_) {
      // Silently fall back to generic worker identity.
    }
  }

  Future<void> _refresh() async {
    await ref.read(workerHomeControllerProvider.notifier).load();
    await ref.read(workerProfileControllerProvider.notifier).loadProfile();
    await ref.read(workerInvitationsControllerProvider.notifier).load();
    await ref.read(workerNotificationsControllerProvider.notifier).load();
    await _loadBasicProfile();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(workerHomeControllerProvider);
    final invitationState = ref.watch(workerInvitationsControllerProvider);
    final profileState = ref.watch(workerProfileControllerProvider);
    final notificationState = ref.watch(workerNotificationsControllerProvider);

    final latestInvitation = _latestInvitation(invitationState.invitations);
    final upcomingJobs = _upcomingJobs(homeState.jobs);
    final completedCount = homeState.jobs.where((job) => job.status.toLowerCase() == 'completed').length;
    const eliteTarget = 10;
    final progress = completedCount >= eliteTarget ? 1.0 : (completedCount / eliteTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: RefreshIndicator(
        color: AppColors.employerPrimary,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            WorkerHomeHeaderSection(
              name: _displayName,
              avatarUrl: _avatarUrl ?? profileState.profile?.avatarUrl,
              unreadCount: notificationState.unreadCount,
            ),
            const SizedBox(height: 16),
            WorkerLatestInvitationSection(
              invitation: latestInvitation,
              isLoading: invitationState.isLoading,
              errorMessage: invitationState.errorMessage,
              respondingInvitationId: invitationState.respondingInvitationId,
              onAccept: (id) async {
                await ref.read(workerInvitationsControllerProvider.notifier).accept(id);
              },
              onDecline: (id) async {
                await ref.read(workerInvitationsControllerProvider.notifier).reject(id);
              },
            ),
            const SizedBox(height: 16),
            WorkerUpcomingWorksSection(
              jobs: upcomingJobs,
              isLoading: homeState.isLoading,
              errorMessage: homeState.errorMessage,
              onViewAll: () => context.goNamed(RouteNames.workerJobs),
            ),
            const SizedBox(height: 16),
            WorkerEliteProgressBanner(
              completedCount: completedCount,
              target: eliteTarget,
              progress: progress,
            ),
            const SizedBox(height: 16),
            const PromotionalAdBanner(),
          ],
        ),
      ),
    );
  }

  JobInvitationEntity? _latestInvitation(List<JobInvitationEntity> invitations) {
    final eligible = invitations
        .where((item) => item.isPending && item.expiresAt.isAfter(DateTime.now()))
        .toList(growable: false);
    if (eligible.isEmpty) return null;
    eligible.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return eligible.first;
  }

  List<dynamic> _upcomingJobs(List<dynamic> jobs) {
    final normalized = List<dynamic>.from(jobs);
    normalized.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return normalized.where((job) {
      final status = (job.status as String).toLowerCase();
      if (status == 'completed' || status == 'cancelled' || status == 'expired') {
        return false;
      }
      return true;
    }).toList(growable: false);
  }
}
