import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';

import '../../domain/entities/employer_trust_entity.dart';
import '../controllers/employer_trust_state.dart';
import '../providers/employer_trust_providers.dart';
import '../widgets/employer_trust_criteria_card.dart';
import '../widgets/employer_trust_explanation.dart';
import '../widgets/employer_trust_status_card.dart';

class EmployerTrustPage extends ConsumerStatefulWidget {
  const EmployerTrustPage({super.key});

  @override
  ConsumerState<EmployerTrustPage> createState() => _EmployerTrustPageState();
}

class _EmployerTrustPageState extends ConsumerState<EmployerTrustPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(employerTrustControllerProvider.notifier).loadTrustDetails();
    });
  }

  Future<void> _refresh() {
    return ref.read(employerTrustControllerProvider.notifier).refreshTrustDetails();
  }

  void _retry() {
    ref.read(employerTrustControllerProvider.notifier).loadTrustDetails();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerTrustControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trust & Reliability')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerTrustState state) {
    if (state.isLoading && !state.hasTrustDetails) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasTrustDetails) {
      return AppErrorView(
        title: 'Unable to load Trust Details',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    final trust = state.trust;
    if (trust == null) {
      return AppErrorView(
        title: 'Unable to load Trust Details',
        message: 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _TrustContent(trust: trust),
    );
  }
}

class _TrustContent extends StatelessWidget {
  const _TrustContent({required this.trust});

  final EmployerTrustEntity trust;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 32),
          children: [
            EmployerTrustStatusCard(trust: trust),
            const SizedBox(height: 18),
            const EmployerTrustExplanation(),
            const SizedBox(height: 20),
            EmployerTrustCriteriaCard(trust: trust),
          ],
        );
      },
    );
  }
}
