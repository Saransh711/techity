import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskParams extends Equatable {
  const CreateTaskParams({
    required this.title,
    required this.description,
    required this.categoryId,
    this.dueDate,
  });

  final String title;
  final String description;
  final String categoryId;
  final DateTime? dueDate;

  @override
  List<Object?> get props => [title, description, categoryId, dueDate];
}

class CreateTask {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(CreateTaskParams params) {
    return _repository.createTask(
      title: params.title,
      description: params.description,
      categoryId: params.categoryId,
      dueDate: params.dueDate,
    );
  }
}
