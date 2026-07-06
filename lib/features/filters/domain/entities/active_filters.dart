import 'package:equatable/equatable.dart';

/// Completion status filter for the task list.
enum TaskStatusFilter { all, pending, completed }

/// Due-date dimension filter (orthogonal to [TaskStatusFilter]).
enum DueDateFilter { all, today, overdue, custom }

/// Persisted filter state for the task list.
class ActiveFilters extends Equatable {
  const ActiveFilters({
    this.categoryId,
    this.status = TaskStatusFilter.all,
    this.dueDateFilter = DueDateFilter.all,
    this.dueDateStart,
    this.dueDateEnd,
    this.searchQuery = '',
  });

  /// `null` means all categories.
  final String? categoryId;
  final TaskStatusFilter status;
  final DueDateFilter dueDateFilter;
  final DateTime? dueDateStart;
  final DateTime? dueDateEnd;
  final String searchQuery;

  static const empty = ActiveFilters();

  /// Whether any non-default filter is active.
  bool get hasActiveFilters =>
      categoryId != null ||
      status != TaskStatusFilter.all ||
      dueDateFilter != DueDateFilter.all ||
      searchQuery.isNotEmpty;

  ActiveFilters copyWith({
    String? categoryId,
    bool clearCategoryId = false,
    TaskStatusFilter? status,
    DueDateFilter? dueDateFilter,
    DateTime? dueDateStart,
    bool clearDueDateStart = false,
    DateTime? dueDateEnd,
    bool clearDueDateEnd = false,
    bool clearCustomDueDate = false,
    String? searchQuery,
    bool clearSearchQuery = false,
  }) {
    return ActiveFilters(
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      status: status ?? this.status,
      dueDateFilter: dueDateFilter ?? this.dueDateFilter,
      dueDateStart: clearCustomDueDate || clearDueDateStart
          ? null
          : (dueDateStart ?? this.dueDateStart),
      dueDateEnd: clearCustomDueDate || clearDueDateEnd
          ? null
          : (dueDateEnd ?? this.dueDateEnd),
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
    categoryId,
    status,
    dueDateFilter,
    dueDateStart,
    dueDateEnd,
    searchQuery,
  ];
}
