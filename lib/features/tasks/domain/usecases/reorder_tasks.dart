import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ReorderTasksParams extends Equatable {
  const ReorderTasksParams({required this.orderedTaskIds});

  /// Complete global order — every task id exactly once.
  final List<String> orderedTaskIds;

  @override
  List<Object?> get props => [orderedTaskIds];
}

/// Reorders tasks and persists contiguous 0-based sort indices.
class ReorderTasks {
  const ReorderTasks(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, List<Task>>> call(ReorderTasksParams params) {
    return _repository.reorderTasks(orderedTaskIds: params.orderedTaskIds);
  }
}
