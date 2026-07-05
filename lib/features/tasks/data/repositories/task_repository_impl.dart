import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/today_completion_stats.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._dataSource);

  final TaskLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = await _dataSource.getAllOrdered();
      return Right(tasks.map((task) => task.toEntity()).toList());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final task = await _dataSource.getById(id);
      return Right(task.toEntity());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({
    required String title,
    required String description,
    required String categoryId,
    DateTime? dueDate,
  }) async {
    try {
      final task = await _dataSource.create(
        title: title,
        description: description,
        categoryId: categoryId,
        dueDate: dueDate,
      );
      return Right(task.toEntity());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final updated = await _dataSource.update(TaskModel.fromEntity(task));
      return Right(updated.toEntity());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, Task>> deleteTask(String id) async {
    try {
      final deleted = await _dataSource.delete(id);
      return Right(deleted.toEntity());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, Task>> restoreTask(Task task) async {
    try {
      final restored = await _dataSource.restore(TaskModel.fromEntity(task));
      return Right(restored.toEntity());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, Task>> toggleTaskComplete(String id) async {
    try {
      final task = await _dataSource.toggleComplete(id);
      return Right(task.toEntity());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> reorderTasks({
    required List<String> orderedTaskIds,
  }) async {
    try {
      final tasks = await _dataSource.reorderByIds(orderedTaskIds);
      return Right(tasks.map((task) => task.toEntity()).toList());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, TodayCompletionStats>>
  getTodayCompletionStats() async {
    try {
      final stats = await _dataSource.getTodayCompletionStats();
      return Right(stats);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, void>> seedDebugTasks({required int count}) async {
    try {
      await _dataSource.seedDebugTasks(count);
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
