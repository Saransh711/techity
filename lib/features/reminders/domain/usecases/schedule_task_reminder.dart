import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../tasks/domain/entities/task.dart';
import '../repositories/task_reminder_repository.dart';
import '../utils/reminder_schedule_utils.dart';

class ScheduleTaskReminderParams extends Equatable {
  const ScheduleTaskReminderParams({required this.task});

  final Task task;

  @override
  List<Object?> get props => [task];
}

class ScheduleTaskReminder {
  const ScheduleTaskReminder(this._repository);

  final TaskReminderRepository _repository;

  Future<Either<Failure, void>> call(ScheduleTaskReminderParams params) {
    if (ReminderScheduleUtils.shouldScheduleReminder(params.task)) {
      return _repository.scheduleReminder(params.task);
    }
    return _repository.cancelReminder(params.task.id);
  }
}
