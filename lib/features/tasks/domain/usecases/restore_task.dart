import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class RestoreTaskParams extends Equatable {
  const RestoreTaskParams({required this.task});

  final Task task;

  @override
  List<Object?> get props => [task];
}

/// Reinserts a deleted task at its original [Task.sortIndex] (undo).
class RestoreTask {
  const RestoreTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(RestoreTaskParams params) {
    return _repository.restoreTask(params.task);
  }
}
