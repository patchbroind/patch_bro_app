import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/employer/invitations/presentation/providers/employer_invitations_providers.dart';
import 'package:patch_bro/features/employer/workers/presentation/widgets/employer_worker_content.dart';

import '../controllers/employer_workers_state.dart';
import '../providers/employer_workers_providers.dart';
import '../widgets/employer_workers_filter_sheet.dart';

class EmployerWorkersPage extends ConsumerStatefulWidget {
  const EmployerWorkersPage({super.key, this.initialTab = EmployerWorkersTab.workers});

  final EmployerWorkersTab initialTab;

  @override
  ConsumerState<EmployerWorkersPage> createState() => _EmployerWorkersPageState();
}

class _EmployerWorkersPageState extends ConsumerState<EmployerWorkersPage> {
  late final TextEditingController _searchController;

  bool _jobFilterApplied = false;

  String? _jobId;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final uri = GoRouterState.of(context).uri;

      _jobId = uri.queryParameters['jobId'];

      final controller = ref.read(employerWorkersControllerProvider.notifier);

      controller.loadWorkers();

      controller.selectTab(widget.initialTab);

      _applyJobFilterFromRoute();

      if (_jobId != null && _jobId!.isNotEmpty) {
        ref.read(employerInvitationsControllerProvider(_jobId!).notifier).initialize();
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
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // JOB FILTER
  // ============================================================

  void _applyJobFilterFromRoute() {
    if (_jobFilterApplied) {
      return;
    }

    final uri = GoRouterState.of(context).uri;

    final category = uri.queryParameters['category']?.trim();

    final skill = uri.queryParameters['skill']?.trim();

    if ((category == null || category.isEmpty) && (skill == null || skill.isEmpty)) {
      return;
    }

    ref
        .read(employerWorkersControllerProvider.notifier)
        .applyJobFilters(category: category ?? 'All', skill: skill ?? '');

    if (skill != null && skill.isNotEmpty) {
      _searchController.text = skill;
    }

    _jobFilterApplied = true;
  }

  // ============================================================
  // FILTER
  // ============================================================

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

  // ============================================================
  // WORKER DETAILS
  // ============================================================

  void _openWorkerDetails(String workerId) {
    context.pushNamed(RouteNames.employerWorkerProfile, extra: workerId);
  }

  // ============================================================
  // FAVOURITE
  // ============================================================

  Future<void> _toggleFavourite(String workerId) async {
    try {
      await ref.read(employerWorkersControllerProvider.notifier).toggleFavourite(workerId);
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to update favourite worker. Please try again.');
    }
  }

  // ============================================================
  // INVITE
  // ============================================================

  Future<void> _inviteWorker(String workerId) async {
    final jobId = _jobId;

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
        'Worker invited successfully. The invitation is valid for 15 minutes.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString();

      AppSnackbar.error(context, message.replaceFirst('Exception: ', ''));
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    try {
      await ref.read(employerWorkersControllerProvider.notifier).refreshWorkers();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to refresh workers. Please try again.');
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(employerWorkersControllerProvider);

    final jobId = _jobId;

    final invitationState = jobId == null || jobId.isEmpty
        ? null
        : ref.watch(employerInvitationsControllerProvider(jobId));

    return Scaffold(
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
          onInviteTap: jobId == null ? null : _inviteWorker,
          showInviteButton: jobId != null && jobId.isNotEmpty,
          invitingWorkerId: invitationState?.invitingWorkerId,
          invitedWorkerIds: invitationState?.activeWorkerIds ?? const {},
        ),
      ),
    );
  }

  void _openNotifications() {
    context.pushNamed(RouteNames.employerNotifications);
  }

  void _updateSearch(String value) {
    ref.read(employerWorkersControllerProvider.notifier).updateSearchQuery(value);
  }

  void _selectTab(EmployerWorkersTab tab) {
    ref.read(employerWorkersControllerProvider.notifier).selectTab(tab);
  }

  void _selectCategory(String category) {
    ref.read(employerWorkersControllerProvider.notifier).selectCategory(category);
  }

  void _loadWorkers() {
    ref.read(employerWorkersControllerProvider.notifier).loadWorkers();
  }
}
