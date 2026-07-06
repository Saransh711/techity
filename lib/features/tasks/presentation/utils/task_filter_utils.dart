import '../../../../core/utils/date_utils.dart';
import '../../../filters/domain/entities/active_filters.dart';
import '../../domain/entities/task.dart';

/// Applies persisted [ActiveFilters] to a task list in memory.
abstract final class TaskFilterUtils {
  static List<Task> apply(List<Task> tasks, ActiveFilters filters) {
    final filtered = tasks.where((task) => _matches(task, filters)).toList();
    filtered.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return filtered;
  }

  static bool _matches(Task task, ActiveFilters filters) {
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.trim().toLowerCase();
      final titleMatch = task.title.toLowerCase().contains(query);
      final descriptionMatch = task.description.toLowerCase().contains(query);
      if (!titleMatch && !descriptionMatch) {
        return false;
      }
    }

    if (filters.categoryId != null && task.categoryId != filters.categoryId) {
      return false;
    }

    switch (filters.status) {
      case TaskStatusFilter.all:
        break;
      case TaskStatusFilter.completed:
        if (!task.isCompleted) {
          return false;
        }
      case TaskStatusFilter.pending:
        if (task.isCompleted) {
          return false;
        }
    }

    switch (filters.dueDateFilter) {
      case DueDateFilter.all:
        break;
      case DueDateFilter.today:
        final dueDate = task.dueDate;
        if (dueDate == null || !DateUtils.isToday(dueDate)) {
          return false;
        }
      case DueDateFilter.overdue:
        final dueDate = task.dueDate;
        if (dueDate == null ||
            task.isCompleted ||
            !DateUtils.isOverdue(dueDate)) {
          return false;
        }
      case DueDateFilter.custom:
        final dueDate = task.dueDate;
        if (dueDate == null) {
          return false;
        }
        final due = DateUtils.startOfDay(dueDate);
        if (filters.dueDateStart != null &&
            due.isBefore(DateUtils.startOfDay(filters.dueDateStart!))) {
          return false;
        }
        if (filters.dueDateEnd != null &&
            due.isAfter(DateUtils.startOfDay(filters.dueDateEnd!))) {
          return false;
        }
    }

    return true;
  }
}
