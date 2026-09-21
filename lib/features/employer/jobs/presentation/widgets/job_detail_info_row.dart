import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class JobDetailInfoRow extends StatelessWidget {
  const JobDetailInfoRow({super.key, 
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      textAlign: TextAlign.right,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(
            color:
                AppColors.textPrimary,
            fontWeight:
                FontWeight.w600,
          ),
    );

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textSecondary,
                ),
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: selectable
              ? SelectableText(
                  value,
                  textAlign:
                      TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                )
              : valueWidget,
        ),
      ],
    );
  }
}