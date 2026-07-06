import 'package:intl/intl.dart';

import '../../features/reminders/domain/utils/reminder_schedule_utils.dart';

abstract final class DateUtils {
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isToday(DateTime date, {DateTime? reference}) {
    final now = startOfDay(reference ?? DateTime.now());
    final target = startOfDay(date);
    return now == target;
  }

  static bool isOverdue(DateTime date, {DateTime? reference}) {
    final today = startOfDay(reference ?? DateTime.now());
    final due = startOfDay(date);
    return due.isBefore(today);
  }

  static String formatDueDate(DateTime dueDate) {
    if (ReminderScheduleUtils.hasExplicitTime(dueDate)) {
      return DateFormat.yMMMd().add_jm().format(dueDate);
    }
    return DateFormat.yMMMd().format(dueDate);
  }
}
