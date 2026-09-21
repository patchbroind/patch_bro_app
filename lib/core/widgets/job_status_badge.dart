import 'package:flutter/material.dart';

class JobStatusBadge
    extends StatelessWidget {
  const JobStatusBadge({super.key, 
    required this.label,
    required this.color,
    this.labelStyle,
    this.horizontalPadding,
    this.verticalPadding,
  });

  final String label;
  final Color color;
  final TextStyle? labelStyle;
  final double? horizontalPadding;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
           EdgeInsets.symmetric(
        horizontal:horizontalPadding?? 10,
        vertical: verticalPadding?? 6,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:labelStyle?? TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}