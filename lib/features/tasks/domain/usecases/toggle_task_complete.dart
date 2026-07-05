import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompleteParams extends Equatable {
  const ToggleTaskCompleteParams({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class ToggleTaskComplete {
  const ToggleTaskComplete(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(ToggleTaskCompleteParams params) {
    return _repository.toggleTaskComplete(params.id);
  }
}
