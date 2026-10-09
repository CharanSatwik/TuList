// File: lib/utils/date_helpers.dart
import 'package:intl/intl.dart';

class DateHelpers {
  static String formatHeaderDate(DateTime date) {
    return DateFormat('EEEE, d MMM').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatTaskDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    final differenceInDays = targetDay.difference(today).inDays;

    final timeStr = formatTime(date);

    if (differenceInDays < 0) {
      return 'Overdue (${DateFormat('MMM d').format(date)}, $timeStr)';
    } else if (differenceInDays == 0) {
      return 'Today, $timeStr';
    } else if (differenceInDays == 1) {
      return 'Tomorrow, $timeStr';
    } else if (differenceInDays < 7) {
      return '${DateFormat('EEE').format(date)}, $timeStr';
    } else {
      return '${DateFormat('MMM d').format(date)}, $timeStr';
    }
  }

  static String getTaskGroup(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final differenceInDays = targetDay.difference(today).inDays;

    if (differenceInDays <= 0) {
      return 'Today';
    } else if (differenceInDays == 1) {
      return 'Tomorrow';
    } else if (differenceInDays <= 7) {
      return 'This week';
    } else {
      return 'Later';
    }
  }
}
