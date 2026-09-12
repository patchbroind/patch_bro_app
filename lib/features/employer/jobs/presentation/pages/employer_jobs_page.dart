import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import '../controllers/employer_jobs_state.dart';
import '../providers/employer_jobs_providers.dart';
import '../widgets/employer_job_card.dart';
import '../widgets/employer_job_filter_tabs.dart';

class EmployerJobsPage extends ConsumerStatefulWidget {
  const EmployerJobsPage({super.key});

  @override
  ConsumerState<EmployerJobsPage> createState() => _EmployerJobsPageState();
}

class _EmployerJobsPageState extends ConsumerState<EmployerJobsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(employerJobsControllerProvider.notifier).loadJobs();
    });
  }

  Future<void> _refresh() async {
    try {
      await ref.read(employerJobsControllerProvider.notifier).refreshJobs();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to refresh jobs. Please try again.');
    }
  }

  void _retry() {
    ref.read(employerJobsControllerProvider.notifier).loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerJobsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerJobsState state) {
    if (state.isLoading && !state.hasJobs) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasJobs) {
      return AppErrorView(
        title: 'Unable to load Jobs',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _JobsContent(
        state: state,
        onFilterSelected: (filter) {
          ref.read(employerJobsControllerProvider.notifier).selectFilter(filter);
        },
      ),
    );
  }
}

class _JobsContent extends StatelessWidget {
  const _JobsContent({required this.state, required this.onFilterSelected});

  final EmployerJobsState state;
  final ValueChanged<EmployerJobsFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
        final jobs = state.filteredJobs;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 28),
          children: [
            EmployerJobFilterTabs(selectedFilter: state.filter, onSelected: onFilterSelected),
            const SizedBox(height: 18),
            if (jobs.isEmpty)
              _JobsEmptyState(filter: state.filter)
            else
              ...jobs.map(
                (job) => Padding(
                  key: ValueKey(job.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EmployerJobCard(job: job),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _JobsEmptyState extends StatelessWidget {
  const _JobsEmptyState({required this.filter});

  final EmployerJobsFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      EmployerJobsFilter.all => 'No jobs found',
      EmployerJobsFilter.active => 'No active jobs',
      EmployerJobsFilter.completed => 'No completed jobs',
      EmployerJobsFilter.cancelled => 'No cancelled jobs',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          const Icon(Icons.work_outline, size: 42, color: AppColors.imagePlaceholderIcon),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
