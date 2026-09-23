import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/employer/invitations/presentation/providers/employer_invitations_providers.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_content.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_invite_job_sheet.dart';

import '../controllers/employer_workers_state.dart';
import '../providers/employer_workers_providers.dart';
import '../widgets/employer_workers_filter_sheet.dart';

class EmployerWorkersPage extends ConsumerStatefulWidget {
  const EmployerWorkersPage({
    super.key,
    this.initialTab = EmployerWorkersTab.workers,
    this.jobId,
    this.category,
    this.skill,
  });

  final EmployerWorkersTab initialTab;

  /// When this is provided, the page is being used as the
  /// job-specific "Invite Workers" screen.
  final String? jobId;

  final String? category;
  final String? skill;

  bool get isJobSpecific => jobId != null && jobId!.trim().isNotEmpty;

  @override
  ConsumerState<EmployerWorkersPage> createState() => _EmployerWorkersPageState();
}

class _EmployerWorkersPageState extends ConsumerState<EmployerWorkersPage> {
  late final TextEditingController _searchController;

  late final ValueNotifier<int> _invitationTimerTick;

  Timer? _invitationTimer;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    _invitationTimerTick = ValueNotifier<int>(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final controller = ref.read(employerWorkersControllerProvider.notifier);

      controller.loadWorkers();

      controller.selectTab(widget.initialTab);

      if (widget.isJobSpecific) {
        _applyJobFilters();

        final jobId = widget.jobId!;

        ref.read(employerInvitationsControllerProvider(jobId).notifier).initialize();

        _startInvitationExpirationTimer();
      }
    });
  }

  @override
  void didUpdateWidget(covariant EmployerWorkersPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTab != widget.initialTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        ref.read(employerWorkersControllerProvider.notifier).selectTab(widget.initialTab);
      });
    }
  }

  @override
  void dispose() {
    _stopInvitationExpirationTimer();

    _invitationTimerTick.dispose();

    _searchController.dispose();

    super.dispose();
  }

  // JOB-SPECIFIC FILTERS

  void _applyJobFilters() {
    final category = widget.category?.trim();

    final skill = widget.skill?.trim();

    if ((category == null || category.isEmpty) && (skill == null || skill.isEmpty)) {
      return;
    }

    ref
        .read(employerWorkersControllerProvider.notifier)
        .applyJobFilters(
          category: category == null || category.isEmpty ? 'All' : category,
          skill: skill ?? '',
        );

    if (skill != null && skill.isNotEmpty) {
      _searchController.text = skill;
    }
  }

  // INVITATION EXPIRATION TIMER

  void _startInvitationExpirationTimer() {
    _stopInvitationExpirationTimer();

    if (!widget.isJobSpecific) {
      return;
    }

    _invitationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      _invitationTimerTick.value++;
    });
  }

  void _stopInvitationExpirationTimer() {
    _invitationTimer?.cancel();
    _invitationTimer = null;
  }

  // FILTER

  Future<void> _openFilter() async {
    final currentFilters = ref.read(employerWorkersControllerProvider).filters;

    final result = await showModalBottomSheet<EmployerWorkersFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: EmployerWorkersFilterSheet(initialFilters: currentFilters),
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    ref.read(employerWorkersControllerProvider.notifier).updateFilters(result);
  }

  // WORKER DETAILS

  void _openWorkerDetails(String workerId) {
    context.pushNamed(RouteNames.employerWorkerProfile, extra: workerId);
  }

  // FAVOURITE

  Future<void> _toggleFavourite(String workerId) async {
    try {
      await ref.read(employerWorkersControllerProvider.notifier).toggleFavourite(workerId);
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to update favourite worker. '
        'Please try again.',
      );
    }
  }

  // JOB-SPECIFIC INVITE

  Future<void> _inviteWorkerForCurrentJob(String workerId) async {
    final jobId = widget.jobId;

    if (jobId == null || jobId.isEmpty) {
      return;
    }

    try {
      await ref.read(employerInvitationsControllerProvider(jobId).notifier).inviteWorker(workerId);

      if (!mounted) {
        return;
      }

      AppSnackbar.success(
        context,
        'Worker invited successfully. '
        'The invitation is valid for 15 minutes.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString();

      AppSnackbar.error(context, message.replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openJobSelector(String workerId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.86,
          child: EmployerWorkerInviteJobSheet(workerId: workerId),
        );
      },
    );
  }

  Future<void> _refresh() async {
    try {
      await ref.read(employerWorkersControllerProvider.notifier).refreshWorkers();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to refresh workers. '
        'Please try again.',
      );
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(employerWorkersControllerProvider);

    final jobId = widget.jobId;

    final invitationState = widget.isJobSpecific
        ? ref.watch(employerInvitationsControllerProvider(jobId!))
        : null;

    return ValueListenableBuilder<int>(
      valueListenable: _invitationTimerTick,
      builder: (context, _, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: widget.isJobSpecific
              ? AppBar(
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  title: const Text('Invite Workers'),
                )
              : null,
          body: SafeArea(
            child: EmployerWorkersContent(
              state: workerState,
              searchController: _searchController,

              onNotificationTap: _openNotifications,

              onSearchChanged: _updateSearch,

              onFilterTap: _openFilter,

              onTabChanged: _selectTab,

              onCategorySelected: _selectCategory,

              onWorkerTap: _openWorkerDetails,

              onFavouriteTap: _toggleFavourite,

              onRefresh: _refresh,

              onRetry: _loadWorkers,

              /*
               * Job-specific screen:
               *     invite directly for this job.
               *
               * Normal Workers tab:
               *     open job selector.
               */
              onInviteTap: widget.isJobSpecific ? _inviteWorkerForCurrentJob : _openJobSelector,

              showInviteButton: true,

              invitingWorkerId: invitationState?.invitingWorkerId,

              invitedWorkerIds: invitationState?.activeWorkerIds ?? const {},
            ),
          ),
        );
      },
    );
  }

  // NOTIFICATIONS

  void _openNotifications() {
    context.pushNamed(RouteNames.employerNotifications);
  }

  // SEARCH

  void _updateSearch(String value) {
    ref.read(employerWorkersControllerProvider.notifier).updateSearchQuery(value);
  }

  // TAB

  void _selectTab(EmployerWorkersTab tab) {
    ref.read(employerWorkersControllerProvider.notifier).selectTab(tab);
  }

  // CATEGORY

  void _selectCategory(String category) {
    ref.read(employerWorkersControllerProvider.notifier).selectCategory(category);
  }

  // LOAD WORKERS

  void _loadWorkers() {
    ref.read(employerWorkersControllerProvider.notifier).loadWorkers();
  }
}
