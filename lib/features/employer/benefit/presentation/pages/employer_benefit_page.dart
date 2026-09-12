import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';

import '../../domain/entities/employer_benefit_entity.dart';
import '../controllers/employer_benefit_state.dart';
import '../providers/employer_benefit_providers.dart';
import '../widgets/employer_benefit_header_card.dart';
import '../widgets/employer_benefit_info_card.dart';
import '../widgets/employer_benefit_progress_card.dart';

class EmployerBenefitPage extends ConsumerStatefulWidget {
  const EmployerBenefitPage({super.key});

  @override
  ConsumerState<EmployerBenefitPage> createState() => _EmployerBenefitPageState();
}

class _EmployerBenefitPageState extends ConsumerState<EmployerBenefitPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(employerBenefitControllerProvider.notifier).loadBenefitDetails();
    });
  }

  Future<void> _refresh() {
    return ref.read(employerBenefitControllerProvider.notifier).refreshBenefitDetails();
  }

  void _retry() {
    ref.read(employerBenefitControllerProvider.notifier).loadBenefitDetails();
  }

  void _viewWorkerProfile() {
    context.pushNamed(RouteNames.workerProfile);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerBenefitControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Employer Benefit')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerBenefitState state) {
    if (state.isLoading && !state.hasBenefit) {
      return const Center(child: CircularProgressIndicator(color: AppColors.employerPrimary));
    }

    if (state.isFailure && !state.hasBenefit) {
      return AppErrorView(
        title: 'Unable to load Employer Benefit',
        message: state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    final benefit = state.benefit;
    if (benefit == null) {
      return AppErrorView(
        title: 'Unable to load Employer Benefit',
        message: 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _BenefitContent(benefit: benefit, onViewWorkerProfile: _viewWorkerProfile),
    );
  }
}

class _BenefitContent extends StatelessWidget {
  const _BenefitContent({required this.benefit, required this.onViewWorkerProfile});

  final EmployerBenefitEntity benefit;
  final VoidCallback onViewWorkerProfile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 30),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  EmployerBenefitHeaderCard(benefit: benefit),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    child: Column(
                      children: [
                        EmployerBenefitProgressCard(benefit: benefit),
                        const SizedBox(height: 12),
                        EmployerBenefitInfoCard(benefit: benefit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppPrimaryButton(label: 'View Worker Profile',
            backgroundColor: AppColors.info,
            onPressed: onViewWorkerProfile,),
            // SizedBox(
            //   width: double.infinity,
            //   child: FilledButton(
            //     onPressed: onViewWorkerProfile,
            //     style: FilledButton.styleFrom(
            //       minimumSize: const Size.fromHeight(48),
            //       backgroundColor: AppColors.info,
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //     ),
            //     child: const Text('View Worker Profile'),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
