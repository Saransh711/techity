import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/task_repository.dart';

class SeedDebugTasksParams extends Equatable {
  const SeedDebugTasksParams({this.count = 100});

  final int count;

  @override
  List<Object?> get props => [count];
}

/// Debug-only bulk insert for scroll performance verification.
class SeedDebugTasks {
  const SeedDebugTasks(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, void>> call(SeedDebugTasksParams params) {
    return _repository.seedDebugTasks(count: params.count);
  }
}
