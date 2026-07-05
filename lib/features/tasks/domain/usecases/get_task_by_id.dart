import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTaskByIdParams extends Equatable {
  const GetTaskByIdParams({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class GetTaskById {
  const GetTaskById(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(GetTaskByIdParams params) {
    return _repository.getTaskById(params.id);
  }
}
