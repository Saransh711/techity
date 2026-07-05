import 'package:equatable/equatable.dart';

import '../../../filters/domain/entities/active_filters.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/today_completion_stats.dart';

sealed class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

final class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

final class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

final class TaskListLoaded extends TaskListState {
  const TaskListLoaded({
    required this.allTasks,
    required this.visibleTasks,
    required this.activeFilters,
    required this.todayProgress,
    this.pendingDelete,
    this.undoSecondsRemaining = 0,
  });

  final List<Task> allTasks;
  final List<Task> visibleTasks;
  final ActiveFilters activeFilters;
  final TodayCompletionStats todayProgress;
  final Task? pendingDelete;
  final int undoSecondsRemaining;

  TaskListLoaded copyWith({
    List<Task>? allTasks,
    List<Task>? visibleTasks,
    ActiveFilters? activeFilters,
    TodayCompletionStats? todayProgress,
    Task? pendingDelete,
    bool clearPendingDelete = false,
    int? undoSecondsRemaining,
  }) {
    return TaskListLoaded(
      allTasks: allTasks ?? this.allTasks,
      visibleTasks: visibleTasks ?? this.visibleTasks,
      activeFilters: activeFilters ?? this.activeFilters,
      todayProgress: todayProgress ?? this.todayProgress,
      pendingDelete:
          clearPendingDelete ? null : (pendingDelete ?? this.pendingDelete),
      undoSecondsRemaining: undoSecondsRemaining ?? this.undoSecondsRemaining,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        visibleTasks,
        activeFilters,
        todayProgress,
        pendingDelete,
        undoSecondsRemaining,
      ];
}

final class TaskListFailure extends TaskListState {
  const TaskListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
