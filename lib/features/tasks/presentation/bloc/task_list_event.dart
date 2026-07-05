import 'package:equatable/equatable.dart';

import '../../../filters/domain/entities/active_filters.dart';

sealed class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTasksRequested extends TaskListEvent {
  const LoadTasksRequested();
}

final class RefreshTasksRequested extends TaskListEvent {
  const RefreshTasksRequested();
}

final class DeleteTaskRequested extends TaskListEvent {
  const DeleteTaskRequested(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

final class RestoreTaskRequested extends TaskListEvent {
  const RestoreTaskRequested();
}

final class UndoCountdownTick extends TaskListEvent {
  const UndoCountdownTick();
}

final class UndoExpired extends TaskListEvent {
  const UndoExpired();
}

final class ToggleTaskCompleteRequested extends TaskListEvent {
  const ToggleTaskCompleteRequested(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

final class ClearFiltersRequested extends TaskListEvent {
  const ClearFiltersRequested();
}

final class ApplyFiltersRequested extends TaskListEvent {
  const ApplyFiltersRequested(this.filters);

  final ActiveFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class ReorderTasksRequested extends TaskListEvent {
  const ReorderTasksRequested(this.orderedVisibleTaskIds);

  /// Post-drag order of currently visible tasks (ids only).
  final List<String> orderedVisibleTaskIds;

  @override
  List<Object?> get props => [orderedVisibleTaskIds];
}

/// Debug-only — inserts 100 tasks for scroll performance verification.
final class SeedDebugTasksRequested extends TaskListEvent {
  const SeedDebugTasksRequested({this.count = 100});

  final int count;

  @override
  List<Object?> get props => [count];
}
