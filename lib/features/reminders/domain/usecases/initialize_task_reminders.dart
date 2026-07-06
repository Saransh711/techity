import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../repositories/task_reminder_repository.dart';

class InitializeTaskReminders {
  const InitializeTaskReminders(this._repository);

  final TaskReminderRepository _repository;

  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.initialize();
  }
}
