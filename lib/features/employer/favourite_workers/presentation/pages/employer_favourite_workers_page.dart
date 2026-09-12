import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import '../../domain/entities/favourite_worker_entity.dart';
import '../controllers/employer_favourite_workers_state.dart';
import '../providers/employer_favourite_workers_providers.dart';
import '../widgets/favourite_worker_card.dart';

class EmployerFavouriteWorkersPage extends ConsumerStatefulWidget {
  const EmployerFavouriteWorkersPage({super.key});

  @override
  ConsumerState<EmployerFavouriteWorkersPage> createState() => _EmployerFavouriteWorkersPageState();
}

class _EmployerFavouriteWorkersPageState extends ConsumerState<EmployerFavouriteWorkersPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(employerFavouriteWorkersControllerProvider.notifier).loadFavouriteWorkers();
    });
  }

  Future<void> _refresh() async {
    try {
      await ref.read(employerFavouriteWorkersControllerProvider.notifier).refreshFavouriteWorkers();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to refresh favourite workers. Please try again.');
    }
  }

  void _retry() {
    ref.read(employerFavouriteWorkersControllerProvider.notifier).loadFavouriteWorkers();
  }

  void _openWorkerProfile(FavouriteWorkerEntity worker) {
    context.pushNamed(RouteNames.workerProfile, extra: worker.id);
  }

  Future<void> _toggleFavourite(FavouriteWorkerEntity worker) async {
    try {
      await ref
          .read(employerFavouriteWorkersControllerProvider.notifier)
          .toggleFavourite(worker.id);
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to update favourite worker. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerFavouriteWorkersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favourite Workers'),centerTitle: true,leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerFavouriteWorkersState state) {
    if (state.isLoading && !state.hasWorkers) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasWorkers) {
      return AppErrorView(
        title: 'Unable to load Favourite Workers',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _FavouriteWorkersContent(
        workers: state.favouriteWorkers,
        togglingWorkerId: state.togglingWorkerId,
        onWorkerTap: _openWorkerProfile,
        onToggleFavourite: _toggleFavourite,
      ),
    );
  }
}

class _FavouriteWorkersContent extends StatelessWidget {
  const _FavouriteWorkersContent({
    required this.workers,
    required this.togglingWorkerId,
    required this.onWorkerTap,
    required this.onToggleFavourite,
  });

  final List<FavouriteWorkerEntity> workers;
  final String? togglingWorkerId;
  final ValueChanged<FavouriteWorkerEntity> onWorkerTap;
  final ValueChanged<FavouriteWorkerEntity> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

        if (workers.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 28),
            children: const [_EmptyFavouriteWorkers()],
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 28),
          itemCount: workers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final worker = workers[index];

            return FavouriteWorkerCard(
              key: ValueKey(worker.id),
              worker: worker,
              isToggling: worker.id == togglingWorkerId,
              onTap: () => onWorkerTap(worker),
              onToggleFavourite: () => onToggleFavourite(worker),
            );
          },
        );
      },
    );
  }
}

class _EmptyFavouriteWorkers extends StatelessWidget {
  const _EmptyFavouriteWorkers();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 44,
            color: AppColors.imagePlaceholderIcon,
          ),
          const SizedBox(height: 14),
          Text(
            'No favourite workers yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Favourite Workers you save will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
