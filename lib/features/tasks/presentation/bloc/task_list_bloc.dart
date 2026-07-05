import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../filters/domain/entities/active_filters.dart';
import '../../../filters/domain/usecases/clear_filters.dart';
import '../../../filters/domain/usecases/get_active_filters.dart';
import '../../../filters/domain/usecases/save_active_filters.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/today_completion_stats.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/get_today_progress.dart';
import '../../domain/usecases/reorder_tasks.dart';
import '../../domain/usecases/restore_task.dart';
import '../../domain/usecases/seed_debug_tasks.dart';
import '../../domain/usecases/toggle_task_complete.dart';
import '../utils/task_filter_utils.dart';
import '../utils/task_reorder_utils.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

/// Loads tasks and applies persisted filters.
///
/// Filter ownership: see `features/filters/presentation/filter_ownership.dart`.
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  TaskListBloc({
    required this._getTasks,
    required this._deleteTask,
    required this._restoreTask,
    required this._toggleTaskComplete,
    required this._reorderTasks,
    required this._getActiveFilters,
    required this._saveActiveFilters,
    required this._clearFilters,
    required this._getTodayProgress,
    required this._seedDebugTasks,
  }) : super(const TaskListInitial()) {
    on<LoadTasksRequested>(_onLoadTasks);
    on<RefreshTasksRequested>(_onRefreshTasks);
    on<DeleteTaskRequested>(_onDeleteTask);
    on<RestoreTaskRequested>(_onRestoreTask);
    on<UndoCountdownTick>(_onUndoCountdownTick);
    on<UndoExpired>(_onUndoExpired);
    on<ToggleTaskCompleteRequested>(_onToggleComplete);
    on<ApplyFiltersRequested>(_onApplyFilters);
    on<ClearFiltersRequested>(_onClearFilters);
    on<ReorderTasksRequested>(_onReorderTasks);
    on<SeedDebugTasksRequested>(_onSeedDebugTasks);
  }

  final GetTasks _getTasks;
  final DeleteTask _deleteTask;
  final RestoreTask _restoreTask;
  final ToggleTaskComplete _toggleTaskComplete;
  final ReorderTasks _reorderTasks;
  final GetActiveFilters _getActiveFilters;
  final SaveActiveFilters _saveActiveFilters;
  final ClearFilters _clearFilters;
  final GetTodayProgress _getTodayProgress;
  final SeedDebugTasks _seedDebugTasks;

  Timer? _undoTimer;

  Future<void> _onLoadTasks(
    LoadTasksRequested event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is! TaskListLoaded) {
      emit(const TaskListLoading());
    }
    await _loadAndEmit(emit);
  }

  Future<void> _onRefreshTasks(
    RefreshTasksRequested event,
    Emitter<TaskListState> emit,
  ) async {
    await _loadAndEmit(
      emit,
      preservePendingDelete: state is TaskListLoaded
          ? (state as TaskListLoaded).pendingDelete
          : null,
      preserveUndoSeconds: state is TaskListLoaded
          ? (state as TaskListLoaded).undoSecondsRemaining
          : 0,
    );
  }

  Future<void> _loadAndEmit(
    Emitter<TaskListState> emit, {
    Task? preservePendingDelete,
    int preserveUndoSeconds = 0,
  }) async {
    // Restore persisted filters before fetching tasks so the first emit is filtered.
    final filtersResult = await _getActiveFilters(const NoParams());

    final filtersFailure = filtersResult.fold(
      (failure) => failure.message,
      (_) => null,
    );
    if (filtersFailure != null) {
      emit(TaskListFailure(filtersFailure));
      return;
    }

    final activeFilters = filtersResult.fold(
      (_) => ActiveFilters.empty,
      (filters) => filters,
    );

    final tasksResult = await _getTasks(const NoParams());
    final progressResult = await _getTodayProgress(const NoParams());

    final failureMessage = tasksResult.fold(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(TaskListFailure(failureMessage));
      return;
    }

    final progressFailure = progressResult.fold(
      (failure) => failure.message,
      (_) => null,
    );
    if (progressFailure != null) {
      emit(TaskListFailure(progressFailure));
      return;
    }

    final allTasks = tasksResult.fold((_) => <Task>[], (tasks) => tasks);
    final todayProgress = progressResult.fold(
      (_) => const TodayCompletionStats(completedCount: 0, totalCount: 0),
      (progress) => progress,
    );

    emit(
      TaskListLoaded(
        allTasks: allTasks,
        visibleTasks: TaskFilterUtils.apply(allTasks, activeFilters),
        activeFilters: activeFilters,
        todayProgress: todayProgress,
        pendingDelete: preservePendingDelete,
        undoSecondsRemaining: preserveUndoSeconds,
      ),
    );
  }

  Future<void> _onDeleteTask(
    DeleteTaskRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final current = state;
    if (current is! TaskListLoaded) {
      return;
    }

    if (current.pendingDelete != null &&
        current.pendingDelete!.id != event.taskId) {
      await _commitPendingDelete(emit, current.pendingDelete!.id);
      final refreshed = state;
      if (refreshed is! TaskListLoaded) {
        return;
      }
      return _scheduleDelete(emit, refreshed, event.taskId);
    }

    await _scheduleDelete(emit, current, event.taskId);
  }

  /// Soft-delete in UI only — persistence delete runs when the undo timer expires.
  Future<void> _scheduleDelete(
    Emitter<TaskListState> emit,
    TaskListLoaded current,
    String taskId,
  ) async {
    final taskIndex = current.allTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) {
      return;
    }

    final task = current.allTasks[taskIndex];
    final withoutTask = List<Task>.from(current.allTasks)..removeAt(taskIndex);

    _undoTimer?.cancel();
    emit(
      current.copyWith(
        allTasks: withoutTask,
        visibleTasks: TaskFilterUtils.apply(withoutTask, current.activeFilters),
        pendingDelete: task,
        undoSecondsRemaining: AppDurations.undoCountdownSeconds,
        todayProgress: _progressWithoutTask(current.todayProgress, task),
      ),
    );
    _startUndoTimer();
  }

  Future<void> _commitPendingDelete(
    Emitter<TaskListState> emit,
    String taskId,
  ) async {
    _undoTimer?.cancel();
    final result = await _deleteTask(DeleteTaskParams(id: taskId));
    await result.fold(
      (failure) async => emit(TaskListFailure(failure.message)),
      (_) async {},
    );
  }

  Future<void> _onRestoreTask(
    RestoreTaskRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final current = state;
    if (current is! TaskListLoaded || current.pendingDelete == null) {
      return;
    }

    _undoTimer?.cancel();
    final pending = current.pendingDelete!;

    final tasksResult = await _getTasks(const NoParams());
    final stillPersisted = tasksResult.fold(
      (_) => false,
      (tasks) => tasks.any((task) => task.id == pending.id),
    );

    if (stillPersisted) {
      // Undo window — task was never removed from storage; reinsert at sortIndex.
      final restored = List<Task>.from(current.allTasks);
      final insertAt = pending.sortIndex.clamp(0, restored.length);
      restored.insert(insertAt, pending);

      emit(
        current.copyWith(
          allTasks: restored,
          visibleTasks: TaskFilterUtils.apply(restored, current.activeFilters),
          clearPendingDelete: true,
          undoSecondsRemaining: 0,
          todayProgress: _progressWithTask(current.todayProgress, pending),
        ),
      );
      return;
    }

    final result = await _restoreTask(RestoreTaskParams(task: pending));

    await result.fold(
      (failure) async => emit(TaskListFailure(failure.message)),
      (_) async => await _loadAndEmit(emit),
    );
  }

  void _onUndoCountdownTick(
    UndoCountdownTick event,
    Emitter<TaskListState> emit,
  ) {
    final current = state;
    if (current is! TaskListLoaded || current.pendingDelete == null) {
      return;
    }

    final nextSeconds = current.undoSecondsRemaining - 1;
    if (nextSeconds <= 0) {
      add(const UndoExpired());
      return;
    }

    emit(current.copyWith(undoSecondsRemaining: nextSeconds));
  }

  Future<void> _onUndoExpired(
    UndoExpired event,
    Emitter<TaskListState> emit,
  ) async {
    _undoTimer?.cancel();
    final current = state;
    if (current is! TaskListLoaded || current.pendingDelete == null) {
      return;
    }

    final taskId = current.pendingDelete!.id;
    final result = await _deleteTask(DeleteTaskParams(id: taskId));

    await result.fold(
      (failure) async {
        emit(TaskListFailure(failure.message));
        add(const RefreshTasksRequested());
      },
      (_) async {
        await _loadAndEmit(emit);
      },
    );
  }

  Future<void> _onToggleComplete(
    ToggleTaskCompleteRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final current = state;
    if (current is! TaskListLoaded) {
      return;
    }

    final optimisticTasks = current.allTasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(
      current.copyWith(
        allTasks: optimisticTasks,
        visibleTasks: TaskFilterUtils.apply(
          optimisticTasks,
          current.activeFilters,
        ),
      ),
    );

    final result = await _toggleTaskComplete(
      ToggleTaskCompleteParams(id: event.taskId),
    );

    await result.fold(
      (failure) async {
        emit(TaskListFailure(failure.message));
        add(const RefreshTasksRequested());
      },
      (_) async {
        await _loadAndEmit(
          emit,
          preservePendingDelete: current.pendingDelete,
          preserveUndoSeconds: current.undoSecondsRemaining,
        );
      },
    );
  }

  Future<void> _onApplyFilters(
    ApplyFiltersRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final saveResult = await _saveActiveFilters(
      SaveActiveFiltersParams(filters: event.filters),
    );

    await saveResult.fold(
      (failure) async => emit(TaskListFailure(failure.message)),
      (_) async {
        final current = state;
        if (current is TaskListLoaded) {
          emit(
            current.copyWith(
              activeFilters: event.filters,
              visibleTasks: TaskFilterUtils.apply(
                current.allTasks,
                event.filters,
              ),
            ),
          );
        } else {
          add(const LoadTasksRequested());
        }
      },
    );
  }

  Future<void> _onClearFilters(
    ClearFiltersRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final result = await _clearFilters(const NoParams());

    await result.fold(
      (failure) async => emit(TaskListFailure(failure.message)),
      (_) async {
        final current = state;
        if (current is TaskListLoaded) {
          emit(
            current.copyWith(
              activeFilters: ActiveFilters.empty,
              visibleTasks: TaskFilterUtils.apply(
                current.allTasks,
                ActiveFilters.empty,
              ),
            ),
          );
        } else {
          add(const LoadTasksRequested());
        }
      },
    );
  }

  Future<void> _onReorderTasks(
    ReorderTasksRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final current = state;
    if (current is! TaskListLoaded || current.pendingDelete != null) {
      return;
    }

    final orderedGlobalIds = TaskReorderUtils.mergeVisibleReorder(
      allTasks: current.allTasks,
      visibleTaskIdsInNewOrder: event.orderedVisibleTaskIds,
    );

    final byId = {for (final task in current.allTasks) task.id: task};
    final optimisticAllTasks = [
      for (var index = 0; index < orderedGlobalIds.length; index++)
        byId[orderedGlobalIds[index]]!.copyWith(sortIndex: index),
    ];

    emit(
      current.copyWith(
        allTasks: optimisticAllTasks,
        visibleTasks: TaskFilterUtils.apply(
          optimisticAllTasks,
          current.activeFilters,
        ),
      ),
    );

    final result = await _reorderTasks(
      ReorderTasksParams(orderedTaskIds: orderedGlobalIds),
    );

    await result.fold(
      (failure) async {
        emit(TaskListFailure(failure.message));
        add(const RefreshTasksRequested());
      },
      (_) async {
        await _loadAndEmit(
          emit,
          preservePendingDelete: current.pendingDelete,
          preserveUndoSeconds: current.undoSecondsRemaining,
        );
      },
    );
  }

  Future<void> _onSeedDebugTasks(
    SeedDebugTasksRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final result = await _seedDebugTasks(
      SeedDebugTasksParams(count: event.count),
    );

    await result.fold(
      (failure) async => emit(TaskListFailure(failure.message)),
      (_) async => await _loadAndEmit(emit),
    );
  }

  void _startUndoTimer() {
    _undoTimer?.cancel();
    _undoTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const UndoCountdownTick()),
    );
  }

  TodayCompletionStats _progressWithoutTask(
    TodayCompletionStats stats,
    Task task,
  ) {
    if (task.dueDate == null || !DateUtils.isToday(task.dueDate!)) {
      return stats;
    }
    return TodayCompletionStats(
      totalCount: stats.totalCount - 1,
      completedCount: stats.completedCount - (task.isCompleted ? 1 : 0),
    );
  }

  TodayCompletionStats _progressWithTask(
    TodayCompletionStats stats,
    Task task,
  ) {
    if (task.dueDate == null || !DateUtils.isToday(task.dueDate!)) {
      return stats;
    }
    return TodayCompletionStats(
      totalCount: stats.totalCount + 1,
      completedCount: stats.completedCount + (task.isCompleted ? 1 : 0),
    );
  }

  @override
  Future<void> close() {
    _undoTimer?.cancel();
    return super.close();
  }
}
