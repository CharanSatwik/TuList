// File: lib/widgets/priority_chip.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color bgColor;

    switch (priority.toLowerCase()) {
      case 'high':
        dotColor = AppTheme.priorityHigh;
        bgColor = AppTheme.priorityHighBg;
        break;
      case 'low':
        dotColor = AppTheme.priorityLow;
        bgColor = AppTheme.priorityLowBg;
        break;
      case 'medium':
      default:
        dotColor = AppTheme.priorityMedium;
        bgColor = AppTheme.priorityMediumBg;
        break;
    }

    final displayLabel = priority.isNotEmpty
        ? '${priority[0].toUpperCase()}${priority.substring(1).toLowerCase()}'
        : 'Medium';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            displayLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}
