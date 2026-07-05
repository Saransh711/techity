import 'package:equatable/equatable.dart';

/// Status filter applied to the task list.
enum TaskStatusFilter {
  all,
  completed,
  pending,
  today,
  overdue,
}

/// Persisted filter state for the task list.
class ActiveFilters extends Equatable {
  const ActiveFilters({
    this.categoryId,
    this.status = TaskStatusFilter.all,
    this.dueDateStart,
    this.dueDateEnd,
  });

  /// `null` means all categories.
  final String? categoryId;
  final TaskStatusFilter status;
  final DateTime? dueDateStart;
  final DateTime? dueDateEnd;

  static const empty = ActiveFilters();

  ActiveFilters copyWith({
    String? categoryId,
    bool clearCategoryId = false,
    TaskStatusFilter? status,
    DateTime? dueDateStart,
    bool clearDueDateStart = false,
    DateTime? dueDateEnd,
    bool clearDueDateEnd = false,
  }) {
    return ActiveFilters(
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      status: status ?? this.status,
      dueDateStart: clearDueDateStart
          ? null
          : (dueDateStart ?? this.dueDateStart),
      dueDateEnd:
          clearDueDateEnd ? null : (dueDateEnd ?? this.dueDateEnd),
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        status,
        dueDateStart,
        dueDateEnd,
      ];
}
