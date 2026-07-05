import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../entities/today_completion_stats.dart';

/// Task persistence contract.
///
/// **List reads:** pull-based [getTasks] — no domain [Stream]. Presentation
/// reloads via Bloc after mutations (see AGENTS.md).
abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();

  Future<Either<Failure, Task>> getTaskById(String id);

  Future<Either<Failure, Task>> createTask({
    required String title,
    required String description,
    required String categoryId,
    DateTime? dueDate,
  });

  Future<Either<Failure, Task>> updateTask(Task task);

  /// Removes the task from the active list and returns a snapshot for undo.
  ///
  /// The returned [Task] preserves [Task.sortIndex] so [restoreTask] can
  /// reinsert at the exact position within the undo window.
  Future<Either<Failure, Task>> deleteTask(String id);

  /// Reinserts a task snapshot (undo). Restores original [Task.sortIndex].
  Future<Either<Failure, Task>> restoreTask(Task task);

  Future<Either<Failure, Task>> toggleTaskComplete(String id);

  /// Reorders tasks and persists contiguous 0-based [Task.sortIndex] values.
  Future<Either<Failure, List<Task>>> reorderTasks({
    required int oldIndex,
    required int newIndex,
  });

  Future<Either<Failure, TodayCompletionStats>> getTodayCompletionStats();
}
