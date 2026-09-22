import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/features/employer/invitations/presentation/controllers/employer_invitations_state.dart';
import 'package:patch_bro/features/employer/invitations/presentation/widgets/employer_job_invitation_section_card.dart';
import 'package:patch_bro/features/employer/invitations/presentation/widgets/employer_job_invitation_section_header.dart';
import 'package:patch_bro/features/employer/invitations/presentation/widgets/employer_job_invitation_tile.dart';

import '../providers/employer_invitations_providers.dart';

class JobInvitationsSection extends ConsumerStatefulWidget {
  const JobInvitationsSection({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<JobInvitationsSection> createState() => _JobInvitationsSectionState();
}

class _JobInvitationsSectionState extends ConsumerState<JobInvitationsSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(employerInvitationsControllerProvider(widget.jobId).notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerInvitationsControllerProvider(widget.jobId));

    if (state.isLoading && !state.hasInvitations) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.status == EmployerInvitationsStatus.failure && !state.hasInvitations) {
      return EmployerJobInvitationSectionCard(
        child: Text(state.errorMessage ?? 'Unable to load invitations.'),
      );
    }

    if (!state.hasInvitations) {
      return EmployerJobInvitationSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployerJobInvitationSectionHeader(activeCount: state.activeCount),
            const SizedBox(height: 12),
            Text(
              'No workers have been invited yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return EmployerJobInvitationSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmployerJobInvitationSectionHeader(activeCount: state.activeCount),

          const SizedBox(height: 14),

          for (final invitation in state.invitations)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EmploterJobInvitationTile(invitation: invitation),
            ),
        ],
      ),
    );
  }
}
