import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks {
  const GetTasks(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, List<Task>>> call(NoParams params) {
    return _repository.getTasks();
  }
}
