import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/repositories/task_reminder_repository.dart';
import '../../domain/utils/reminder_schedule_utils.dart';
import '../services/local_notification_service.dart';

class TaskReminderRepositoryImpl implements TaskReminderRepository {
  const TaskReminderRepositoryImpl(this._notificationService);

  final LocalNotificationService _notificationService;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await _notificationService.initialize();
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final granted = await _notificationService.requestPermissions();
      return Right(granted);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleReminder(Task task) async {
    try {
      final dueDate = task.dueDate;
      if (dueDate == null) {
        return const Right(null);
      }

      final notificationId = _notificationService.notificationIdForTask(
        task.id,
      );
      await _notificationService.cancel(notificationId);

      final scheduledAt = ReminderScheduleUtils.reminderDateTime(dueDate);
      if (!scheduledAt.isAfter(DateTime.now())) {
        return const Right(null);
      }

      await _notificationService.schedule(
        id: notificationId,
        title: AppStrings.appTitle,
        body: AppStrings.taskReminderBody(task.title),
        scheduledDate: scheduledAt,
      );
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReminder(String taskId) async {
    try {
      final notificationId = _notificationService.notificationIdForTask(
        taskId,
      );
      await _notificationService.cancel(notificationId);
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
