import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../repositories/task_reminder_repository.dart';

class RequestReminderPermissions {
  const RequestReminderPermissions(this._repository);

  final TaskReminderRepository _repository;

  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.requestPermissions();
  }
}
