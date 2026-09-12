import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

import '../../domain/entities/employer_trust_entity.dart';

class EmployerTrustStatusCard extends StatelessWidget {
  const EmployerTrustStatusCard({
    super.key,
    required this.trust,
  });

  final EmployerTrustEntity trust;

  @override
  Widget build(BuildContext context) {
    final statusColor = trust.isTrusted ? AppColors.employerPrimary : AppColors.error;
    final backgroundColor = trust.isTrusted
        ? AppColors.employerLight.withValues(alpha: 0.45)
        : AppColors.error.withValues(alpha: 0.05);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _TrustShield(isTrusted: trust.isTrusted),
          const SizedBox(height: 10),
          Text(
            trust.statusTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              trust.statusDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _TrustSummaryRow(
                  icon: Icons.check_circle_rounded,
                  color: statusColor,
                  text: trust.successfulJobsLabel,
                ),
                const SizedBox(height: 9),
                _TrustSummaryRow(
                  icon: Icons.event_busy_rounded,
                  color: statusColor,
                  text: trust.cancellationLabel,
                ),
                const SizedBox(height: 9),
                _TrustSummaryRow(
                  icon: trust.isGoodStanding
                      ? Icons.check_circle_rounded
                      : Icons.warning_rounded,
                  color: trust.isGoodStanding ? statusColor : AppColors.warning,
                  text: trust.standingLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustShield extends StatelessWidget {
  const _TrustShield({required this.isTrusted});

  final bool isTrusted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield_rounded,
            size: 64,
            color: isTrusted ? AppColors.employerPrimary : AppColors.error,
          ),
          Icon(
            isTrusted ? Icons.check_rounded : Icons.close_rounded,
            size: 31,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class _TrustSummaryRow extends StatelessWidget {
  const _TrustSummaryRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
