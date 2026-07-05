import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../entities/today_completion_stats.dart';
import '../repositories/task_repository.dart';

class GetTodayProgress {
  const GetTodayProgress(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, TodayCompletionStats>> call(NoParams params) {
    return _repository.getTodayCompletionStats();
  }
}
