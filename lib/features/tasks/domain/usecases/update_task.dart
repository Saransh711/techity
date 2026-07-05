import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskParams extends Equatable {
  const UpdateTaskParams({required this.task});

  final Task task;

  @override
  List<Object?> get props => [task];
}

class UpdateTask {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(UpdateTaskParams params) {
    return _repository.updateTask(params.task);
  }
}
