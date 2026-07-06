import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/task_reminder_repository.dart';

class CancelTaskReminderParams extends Equatable {
  const CancelTaskReminderParams({required this.taskId});

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class CancelTaskReminder {
  const CancelTaskReminder(this._repository);

  final TaskReminderRepository _repository;

  Future<Either<Failure, void>> call(CancelTaskReminderParams params) {
    return _repository.cancelReminder(params.taskId);
  }
}
