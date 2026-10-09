// File: lib/widgets/filter_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class FilterBar extends StatelessWidget {
  final PriorityFilter selectedPriority;
  final StatusFilter selectedStatus;
  final ValueChanged<PriorityFilter> onPriorityChanged;
  final ValueChanged<StatusFilter> onStatusChanged;

  const FilterBar({
    super.key,
    required this.selectedPriority,
    required this.selectedStatus,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status filters row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildStatusChip(StatusFilter.all, 'All Tasks'),
              const SizedBox(width: 8),
              _buildStatusChip(StatusFilter.incomplete, 'Incomplete'),
              const SizedBox(width: 8),
              _buildStatusChip(StatusFilter.completed, 'Completed'),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Priority filters row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildPriorityChip(PriorityFilter.all, 'All Priority'),
              const SizedBox(width: 8),
              _buildPriorityChip(PriorityFilter.low, 'Low'),
              const SizedBox(width: 8),
              _buildPriorityChip(PriorityFilter.medium, 'Medium'),
              const SizedBox(width: 8),
              _buildPriorityChip(PriorityFilter.high, 'High'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(StatusFilter filter, String label) {
    final isSelected = selectedStatus == filter;

    return GestureDetector(
      onTap: () => onStatusChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.oliveGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.oliveGreen
                : const Color(0xFFE2E4EC),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.oliveGreen.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(PriorityFilter filter, String label) {
    final isSelected = selectedPriority == filter;

    Color activeColor = AppTheme.oliveGreen;
    if (filter == PriorityFilter.high) activeColor = AppTheme.priorityHigh;
    if (filter == PriorityFilter.medium) activeColor = AppTheme.priorityMedium;
    if (filter == PriorityFilter.low) activeColor = AppTheme.priorityLow;

    return GestureDetector(
      onTap: () => onPriorityChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (filter == PriorityFilter.all
                  ? AppTheme.oliveGreen
                  : activeColor.withValues(alpha: 0.15))
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E4EC),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filter != PriorityFilter.all) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (filter == PriorityFilter.all ? Colors.white : activeColor)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
