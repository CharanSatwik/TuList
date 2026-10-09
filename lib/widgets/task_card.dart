// File: lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import 'delete_task_dialog.dart';
import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.deleteRedBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppTheme.deleteRed,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: task.isCompleted ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: task.isCompleted
                  ? AppTheme.borderSubtle
                  : AppTheme.borderLight,
              width: 1,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Checkbox matching design reference
                    GestureDetector(
                      onTap: onToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? AppTheme.secondary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: task.isCompleted
                                  ? AppTheme.secondary
                                  : AppTheme.secondary.withValues(alpha: 0.65),
                              width: 2.0,
                            ),
                          ),
                          child: task.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: AppTheme.pureWhite,
                                )
                              : null,
                        ),
                      ),
                    ),

                    // Task Content (Title, optional description, and due date underneath)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? AppTheme.textTertiary
                                  : AppTheme.textPrimary,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppTheme.textTertiary,
                            ),
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: task.isCompleted
                                    ? AppTheme.textTertiary
                                    : (task.priority.toLowerCase() == 'high' ||
                                            task.dueDate.isBefore(DateTime.now()))
                                        ? AppTheme.secondary
                                        : AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  DateHelpers.formatTaskDueDate(task.dueDate),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: (task.priority.toLowerCase() == 'high' ||
                                            task.dueDate.isBefore(DateTime.now())) &&
                                            !task.isCompleted
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: task.isCompleted
                                        ? AppTheme.textTertiary
                                        : (task.priority.toLowerCase() == 'high' ||
                                                task.dueDate.isBefore(DateTime.now()))
                                            ? AppTheme.secondary
                                            : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Priority Pill Tag
                    PriorityChip(priority: task.priority),

                    const SizedBox(width: 6),

                    // Explicit Delete Button
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await showDeleteTaskDialog(
                          context,
                          taskTitle: task.title,
                        );
                        if (confirmed) {
                          onDelete();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.secondarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
