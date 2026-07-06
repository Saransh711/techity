import '../../../tasks/domain/entities/task.dart';

/// Pure-Dart helpers for mapping task due dates to reminder fire times.
abstract final class ReminderScheduleUtils {
  static const defaultHour = 9;
  static const defaultMinute = 0;

  static bool hasExplicitTime(DateTime dueDate) {
    return dueDate.hour != 0 ||
        dueDate.minute != 0 ||
        dueDate.second != 0 ||
        dueDate.millisecond != 0;
  }

  static DateTime reminderDateTime(DateTime dueDate) {
    if (hasExplicitTime(dueDate)) {
      return dueDate;
    }
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      defaultHour,
      defaultMinute,
    );
  }

  static bool shouldScheduleReminder(Task task, {DateTime? reference}) {
    if (task.dueDate == null || task.isCompleted) {
      return false;
    }
    final when = reminderDateTime(task.dueDate!);
    return when.isAfter(reference ?? DateTime.now());
  }

  static int notificationIdForTask(String taskId) {
    return taskId.hashCode.abs();
  }
}
