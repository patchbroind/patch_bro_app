import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import 'package:patch_bro/features/worker/shared/presentation/widgets/worker_work_card.dart';

import '../controllers/worker_jobs_state.dart';
import '../providers/worker_jobs_providers.dart';
import '../widgets/worker_jobs_empty_state.dart';
import '../widgets/worker_jobs_tab_bar.dart';

class WorkerJobsPage extends ConsumerStatefulWidget {
  const WorkerJobsPage({super.key});

  @override
  ConsumerState<WorkerJobsPage> createState() => _WorkerJobsPageState();
}

class _WorkerJobsPageState extends ConsumerState<WorkerJobsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(workerJobsControllerProvider.notifier).loadJobs();
    });
  }

  Future<void> _refresh() async {
    try {
      await ref.read(workerJobsControllerProvider.notifier).refreshJobs();
    } catch (_) {
      // Existing jobs remain visible if refresh fails.
    }
  }

  void _retry() {
    ref.read(workerJobsControllerProvider.notifier).loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerJobsControllerProvider);

    return Scaffold(
      backgroundColor: WorkerColors.homeBackground,
      appBar: AppBar(
        title: const Text('My Works'),
        backgroundColor: WorkerColors.homeBackground,
        foregroundColor: WorkerColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: WorkerJobsTabBar(
                selectedTab: state.selectedTab,
                onTabSelected: (tab) {
                  ref.read(workerJobsControllerProvider.notifier).selectTab(tab);
                },
              ),
            ),

            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(WorkerJobsState state) {
    if (state.isLoading && !state.hasJobs) {
      return const Center(child: CircularProgressIndicator(color: WorkerColors.homePrimary));
    }

    if (state.hasError && !state.hasJobs) {
      return AppErrorView(
        title: 'Unable to load works',
        message: 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        iconColor: WorkerColors.homePrimary,
        onRetry: _retry,
      );
    }

    final jobs = state.filteredJobs;

    return RefreshIndicator(
      color: WorkerColors.homePrimary,
      onRefresh: _refresh,
      child: jobs.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: WorkerJobsEmptyState(tab: state.selectedTab),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: jobs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final job = jobs[index];

                return WorkerWorkCard(
                  key: ValueKey(job.id),
                  job: job,
                  onTap: () {
                    context.pushNamed(
                      RouteNames.workerJobDetails,
                      pathParameters: {'jobId': job.id},
                      extra: job,
                    );
                  },
                );
              },
            ),
    );
  }
}
