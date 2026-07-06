import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/errors/failure.dart';
import '../../../tasks/domain/entities/task.dart';

abstract class TaskReminderRepository {
  Future<Either<Failure, void>> initialize();

  Future<Either<Failure, bool>> requestPermissions();

  Future<Either<Failure, void>> scheduleReminder(Task task);

  Future<Either<Failure, void>> cancelReminder(String taskId);
}
