// File: lib/widgets/filter_box.dart
import 'package:flutter/material.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class FilterBox extends StatelessWidget {
  final PriorityFilter selectedPriority;
  final StatusFilter selectedStatus;
  final ValueChanged<PriorityFilter> onPriorityChanged;
  final ValueChanged<StatusFilter> onStatusChanged;
  final VoidCallback onReset;
  final int totalTasksCount;
  final int filteredTasksCount;

  const FilterBox({
    super.key,
    required this.selectedPriority,
    required this.selectedStatus,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    required this.onReset,
    required this.totalTasksCount,
    required this.filteredTasksCount,
  });

  bool get hasActiveFilter =>
      selectedPriority != PriorityFilter.all ||
      selectedStatus != StatusFilter.all;

  int get activeFiltersCount {
    int count = 0;
    if (selectedPriority != PriorityFilter.all) count++;
    if (selectedStatus != StatusFilter.all) count++;
    return count;
  }

  static void show(
    BuildContext context, {
    required PriorityFilter selectedPriority,
    required StatusFilter selectedStatus,
    required int totalTasksCount,
    required ValueChanged<PriorityFilter> onPriorityChanged,
    required ValueChanged<StatusFilter> onStatusChanged,
    required VoidCallback onReset,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: Responsive.modalMaxWidth),
      builder: (modalContext) {
        return _FilterBottomSheetContent(
          initialPriority: selectedPriority,
          initialStatus: selectedStatus,
          totalTasksCount: totalTasksCount,
          onApply: (newPriority, newStatus) {
            onPriorityChanged(newPriority);
            onStatusChanged(newStatus);
            Navigator.pop(modalContext);
          },
          onReset: () {
            onReset();
            Navigator.pop(modalContext);
          },
        );
      },
    );
  }

  void _openFilterModal(BuildContext context) {
    show(
      context,
      selectedPriority: selectedPriority,
      selectedStatus: selectedStatus,
      totalTasksCount: totalTasksCount,
      onPriorityChanged: onPriorityChanged,
      onStatusChanged: onStatusChanged,
      onReset: onReset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Filter Bar Card
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
          ),
          child: InkWell(
            onTap: () => _openFilterModal(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasActiveFilter
                      ? AppTheme.oliveGreen
                      : AppTheme.borderLight,
                  width: hasActiveFilter ? 1.4 : 1,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: hasActiveFilter
                          ? AppTheme.oliveGreen
                          : AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: hasActiveFilter
                          ? AppTheme.pureWhite
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Filter Tasks',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (hasActiveFilter) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.oliveGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$activeFiltersCount',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.pureWhite,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          hasActiveFilter
                              ? 'Showing $filteredTasksCount of $totalTasksCount tasks'
                              : 'All tasks (by due date)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasActiveFilter)
                    GestureDetector(
                      onTap: onReset,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppTheme.textTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),

        // Active filter pills row (if any)
        if (hasActiveFilter) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
            ),
            child: Row(
              children: [
                if (selectedStatus != StatusFilter.all)
                  _buildActivePill(
                    label: selectedStatus == StatusFilter.completed
                        ? 'Completed'
                        : 'Incomplete',
                    onRemove: () => onStatusChanged(StatusFilter.all),
                  ),
                if (selectedPriority != PriorityFilter.all) ...[
                  const SizedBox(width: 8),
                  _buildActivePill(
                    label:
                        '${selectedPriority.name[0].toUpperCase()}${selectedPriority.name.substring(1)} Priority',
                    dotColor: _priorityColor(selectedPriority),
                    onRemove: () => onPriorityChanged(PriorityFilter.all),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActivePill({
    required String label,
    Color? dotColor,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(PriorityFilter filter) {
    switch (filter) {
      case PriorityFilter.high:
        return AppTheme.priorityHigh;
      case PriorityFilter.medium:
        return AppTheme.priorityMedium;
      case PriorityFilter.low:
        return AppTheme.priorityLow;
      case PriorityFilter.all:
        return AppTheme.textSecondary;
    }
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final PriorityFilter initialPriority;
  final StatusFilter initialStatus;
  final int totalTasksCount;
  final void Function(PriorityFilter, StatusFilter) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheetContent({
    required this.initialPriority,
    required this.initialStatus,
    required this.totalTasksCount,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late PriorityFilter _tempPriority;
  late StatusFilter _tempStatus;

  @override
  void initState() {
    super.initState();
    _tempPriority = widget.initialPriority;
    _tempStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Tasks',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempPriority = PriorityFilter.all;
                    _tempStatus = StatusFilter.all;
                  });
                  widget.onReset();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reset all',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Section 1: Status Filter
          Text(
            'STATUS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildChoiceChip(
                label: 'All',
                isSelected: _tempStatus == StatusFilter.all,
                onTap: () => setState(() => _tempStatus = StatusFilter.all),
              ),
              const SizedBox(width: 8),
              _buildChoiceChip(
                label: 'Incomplete',
                isSelected: _tempStatus == StatusFilter.incomplete,
                onTap: () =>
                    setState(() => _tempStatus = StatusFilter.incomplete),
              ),
              const SizedBox(width: 8),
              _buildChoiceChip(
                label: 'Completed',
                isSelected: _tempStatus == StatusFilter.completed,
                onTap: () =>
                    setState(() => _tempStatus = StatusFilter.completed),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 2: Priority Filter
          Text(
            'PRIORITY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'All',
                isSelected: _tempPriority == PriorityFilter.all,
                onTap: () => setState(() => _tempPriority = PriorityFilter.all),
              ),
              _buildChoiceChip(
                label: 'Low',
                dotColor: AppTheme.priorityLow,
                isSelected: _tempPriority == PriorityFilter.low,
                onTap: () => setState(() => _tempPriority = PriorityFilter.low),
              ),
              _buildChoiceChip(
                label: 'Medium',
                dotColor: AppTheme.priorityMedium,
                isSelected: _tempPriority == PriorityFilter.medium,
                onTap: () =>
                    setState(() => _tempPriority = PriorityFilter.medium),
              ),
              _buildChoiceChip(
                label: 'High',
                dotColor: AppTheme.priorityHigh,
                isSelected: _tempPriority == PriorityFilter.high,
                onTap: () =>
                    setState(() => _tempPriority = PriorityFilter.high),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_tempPriority, _tempStatus),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.oliveGreen,
                foregroundColor: AppTheme.pureWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildChoiceChip({
    required String label,
    Color? dotColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.oliveGreen : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.oliveGreen : AppTheme.borderLight,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.pureWhite : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.pureWhite : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
