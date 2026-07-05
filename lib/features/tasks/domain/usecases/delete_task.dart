import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class DeleteTaskParams extends Equatable {
  const DeleteTaskParams({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Removes a task and returns its snapshot for the undo buffer.
class DeleteTask {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(DeleteTaskParams params) {
    return _repository.deleteTask(params.id);
  }
}
