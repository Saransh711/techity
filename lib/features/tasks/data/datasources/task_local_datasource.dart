import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/today_completion_stats.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllOrdered();

  Future<TaskModel> getById(String id);

  Future<TaskModel> create({
    required String title,
    required String description,
    required String categoryId,
    DateTime? dueDate,
  });

  Future<TaskModel> update(TaskModel task);

  Future<TaskModel> delete(String id);

  Future<TaskModel> restore(TaskModel task);

  Future<TaskModel> toggleComplete(String id);

  Future<List<TaskModel>> reorder({
    required int oldIndex,
    required int newIndex,
  });

  Future<TodayCompletionStats> getTodayCompletionStats();

  Future<void> seedSampleTasksIfEmpty();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl({
    required this.tasksBox,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final Box<TaskModel> tasksBox;
  final Uuid _uuid;

  @override
  Future<List<TaskModel>> getAllOrdered() async {
    final tasks = tasksBox.values.toList(growable: false);
    tasks.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return tasks;
  }

  @override
  Future<TaskModel> getById(String id) async {
    final task = tasksBox.get(id);
    if (task == null) {
      throw ArgumentError('Task not found: $id');
    }
    return task;
  }

  @override
  Future<TaskModel> create({
    required String title,
    required String description,
    required String categoryId,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final existing = await getAllOrdered();
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      categoryId: categoryId,
      isCompleted: false,
      sortIndex: existing.length,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
    );
    await tasksBox.put(task.id, task);
    return task;
  }

  @override
  Future<TaskModel> update(TaskModel task) async {
    if (!tasksBox.containsKey(task.id)) {
      throw ArgumentError('Task not found: ${task.id}');
    }
    final updated = task.copyWithModel(updatedAt: DateTime.now());
    await tasksBox.put(updated.id, updated);
    return updated;
  }

  @override
  Future<TaskModel> delete(String id) async {
    final task = await getById(id);
    await tasksBox.delete(id);
    return task;
  }

  @override
  Future<TaskModel> restore(TaskModel task) async {
    final ordered = await getAllOrdered();
    final updates = <String, TaskModel>{};

    for (final existing in ordered) {
      if (existing.sortIndex >= task.sortIndex) {
        updates[existing.id] = existing.copyWithModel(
          sortIndex: existing.sortIndex + 1,
          updatedAt: DateTime.now(),
        );
      }
    }

    final restored = task.copyWithModel(updatedAt: DateTime.now());
    updates[restored.id] = restored;

    if (updates.isNotEmpty) {
      await tasksBox.putAll(updates);
    }

    return restored;
  }

  @override
  Future<TaskModel> toggleComplete(String id) async {
    final task = await getById(id);
    final now = DateTime.now();
    final updated = task.copyWithModel(
      isCompleted: !task.isCompleted,
      completedAt: task.isCompleted ? null : now,
      clearCompletedAt: task.isCompleted,
      updatedAt: now,
    );
    await tasksBox.put(updated.id, updated);
    return updated;
  }

  @override
  Future<List<TaskModel>> reorder({
    required int oldIndex,
    required int newIndex,
  }) async {
    final tasks = (await getAllOrdered()).toList(growable: true);
    if (oldIndex < 0 ||
        oldIndex >= tasks.length ||
        newIndex < 0 ||
        newIndex >= tasks.length) {
      throw ArgumentError(
        'Invalid reorder indices: oldIndex=$oldIndex, newIndex=$newIndex',
      );
    }

    final moved = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, moved);

    final now = DateTime.now();
    final updates = <String, TaskModel>{};
    for (var index = 0; index < tasks.length; index++) {
      final task = tasks[index];
      updates[task.id] = task.copyWithModel(
        sortIndex: index,
        updatedAt: now,
      );
    }

    await tasksBox.putAll(updates);
    return getAllOrdered();
  }

  /// Today progress rule:
  /// - [TodayCompletionStats.totalCount]: tasks with a [Task.dueDate] on today.
  /// - [TodayCompletionStats.completedCount]: those due-today tasks with
  ///   [Task.isCompleted] == true.
  @override
  Future<TodayCompletionStats> getTodayCompletionStats() async {
    final tasks = await getAllOrdered();
    final dueToday =
        tasks.where((task) => task.dueDate != null && DateUtils.isToday(task.dueDate!));
    final completedDueToday =
        dueToday.where((task) => task.isCompleted).length;

    return TodayCompletionStats(
      completedCount: completedDueToday,
      totalCount: dueToday.length,
    );
  }

  @override
  Future<void> seedSampleTasksIfEmpty() async {
    if (tasksBox.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    final samples = [
      TaskModel(
        id: _uuid.v4(),
        title: 'Plan sprint backlog',
        description: 'Review priorities for the week ahead.',
        categoryId: CategoryConstants.workId,
        isCompleted: false,
        sortIndex: 0,
        createdAt: now,
        updatedAt: now,
        dueDate: today,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Grocery run',
        description: 'Pick up fruit and vegetables.',
        categoryId: CategoryConstants.personalId,
        isCompleted: false,
        sortIndex: 1,
        createdAt: now,
        updatedAt: now,
        dueDate: tomorrow,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Submit expense report',
        description: 'Overdue — submit before end of day.',
        categoryId: CategoryConstants.urgentId,
        isCompleted: true,
        sortIndex: 2,
        createdAt: now,
        updatedAt: now,
        dueDate: yesterday,
        completedAt: now,
      ),
    ];

    await tasksBox.putAll({for (final task in samples) task.id: task});
  }
}
