import 'package:get_it/get_it.dart';

import '../../features/filters/data/datasources/filter_local_datasource.dart';
import '../../features/filters/data/repositories/filter_repository_impl.dart';
import '../../features/filters/domain/repositories/filter_repository.dart';
import '../../features/filters/domain/usecases/clear_filters.dart';
import '../../features/filters/domain/usecases/get_active_filters.dart';
import '../../features/filters/domain/usecases/save_active_filters.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/entities/app_theme_preference.dart';
import '../../features/settings/domain/usecases/get_theme_mode.dart';
import '../../features/settings/domain/usecases/save_theme_mode.dart';
import '../../features/settings/presentation/bloc/theme_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/reminders/data/repositories/task_reminder_repository_impl.dart';
import '../../features/reminders/data/services/local_notification_service.dart';
import '../../features/reminders/domain/repositories/task_reminder_repository.dart';
import '../../features/reminders/domain/usecases/cancel_task_reminder.dart';
import '../../features/reminders/domain/usecases/initialize_task_reminders.dart';
import '../../features/reminders/domain/usecases/request_reminder_permissions.dart';
import '../../features/reminders/domain/usecases/schedule_task_reminder.dart';
import '../../features/tasks/presentation/bloc/task_form_bloc.dart';
import '../../features/tasks/presentation/bloc/task_list_bloc.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/domain/usecases/get_task_by_id.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/get_today_progress.dart';
import '../../features/tasks/domain/usecases/reorder_tasks.dart';
import '../../features/tasks/domain/usecases/restore_task.dart';
import '../../features/tasks/domain/usecases/seed_debug_tasks.dart';
import '../../features/tasks/domain/usecases/toggle_task_complete.dart';
import '../../features/tasks/domain/usecases/update_task.dart';

final GetIt getIt = GetIt.instance;

/// Registers repositories and use cases. Data sources must already be
/// registered via [initializeHiveStorage] before calling this.
void configureDependencies() {
  _registerPlatformServices();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerPlatformServices() {
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );
  getIt.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(getIt<FlutterLocalNotificationsPlugin>()),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<SettingsLocalDataSource>()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<TaskLocalDataSource>()),
  );
  getIt.registerLazySingleton<FilterRepository>(
    () => FilterRepositoryImpl(getIt<FilterLocalDataSource>()),
  );
  getIt.registerLazySingleton<TaskReminderRepository>(
    () => TaskReminderRepositoryImpl(getIt<LocalNotificationService>()),
  );
}

void _registerUseCases() {
  getIt.registerLazySingleton<GetThemeMode>(
    () => GetThemeMode(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton<SaveThemeMode>(
    () => SaveThemeMode(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton<GetTasks>(
    () => GetTasks(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<GetTaskById>(
    () => GetTaskById(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<CreateTask>(
    () => CreateTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<UpdateTask>(
    () => UpdateTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<DeleteTask>(
    () => DeleteTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<RestoreTask>(
    () => RestoreTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ToggleTaskComplete>(
    () => ToggleTaskComplete(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ReorderTasks>(
    () => ReorderTasks(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<GetTodayProgress>(
    () => GetTodayProgress(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<SeedDebugTasks>(
    () => SeedDebugTasks(getIt<TaskRepository>()),
  );

  getIt.registerLazySingleton<GetActiveFilters>(
    () => GetActiveFilters(getIt<FilterRepository>()),
  );
  getIt.registerLazySingleton<SaveActiveFilters>(
    () => SaveActiveFilters(getIt<FilterRepository>()),
  );
  getIt.registerLazySingleton<ClearFilters>(
    () => ClearFilters(getIt<FilterRepository>()),
  );

  getIt.registerLazySingleton<InitializeTaskReminders>(
    () => InitializeTaskReminders(getIt<TaskReminderRepository>()),
  );
  getIt.registerLazySingleton<RequestReminderPermissions>(
    () => RequestReminderPermissions(getIt<TaskReminderRepository>()),
  );
  getIt.registerLazySingleton<ScheduleTaskReminder>(
    () => ScheduleTaskReminder(getIt<TaskReminderRepository>()),
  );
  getIt.registerLazySingleton<CancelTaskReminder>(
    () => CancelTaskReminder(getIt<TaskReminderRepository>()),
  );
}

void _registerBlocs() {
  getIt.registerFactoryParam<ThemeBloc, AppThemePreference, void>(
    (initialPreference, _) => ThemeBloc(
      getThemeMode: getIt(),
      saveThemeMode: getIt(),
      initialPreference: initialPreference,
    ),
  );

  getIt.registerFactory<TaskListBloc>(
    () => TaskListBloc(
      getTasks: getIt(),
      deleteTask: getIt(),
      restoreTask: getIt(),
      toggleTaskComplete: getIt(),
      reorderTasks: getIt(),
      getActiveFilters: getIt(),
      saveActiveFilters: getIt(),
      clearFilters: getIt(),
      getTodayProgress: getIt(),
      seedDebugTasks: getIt(),
      scheduleTaskReminder: getIt(),
      cancelTaskReminder: getIt(),
    ),
  );

  getIt.registerFactoryParam<TaskFormBloc, String?, void>(
    (taskId, _) => TaskFormBloc(
      getTaskById: getIt(),
      createTask: getIt(),
      updateTask: getIt(),
      scheduleTaskReminder: getIt(),
      taskId: taskId,
    ),
  );
}
