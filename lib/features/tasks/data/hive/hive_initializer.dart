import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../filters/data/datasources/filter_local_datasource.dart';
import '../../../filters/data/models/filter_model.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

/// Registers Hive adapters, opens boxes, and registers data sources.
///
/// Must run after [Hive.initFlutter] and before [configureDependencies].
Future<void> initializeHiveStorage(GetIt getIt) async {
  _registerAdapters();

  final settingsBox = await Hive.openBox<dynamic>(AppKeys.settingsBox);
  final tasksBox = await Hive.openBox<TaskModel>(AppKeys.tasksBox);
  final filtersBox = await Hive.openBox<dynamic>(AppKeys.filtersBox);

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(settingsBox: settingsBox),
  );
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(tasksBox: tasksBox),
  );
  getIt.registerLazySingleton<FilterLocalDataSource>(
    () => FilterLocalDataSourceImpl(filtersBox: filtersBox),
  );

  await getIt<TaskLocalDataSource>().seedSampleTasksIfEmpty();
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(AppKeys.taskTypeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(AppKeys.filterStateTypeId)) {
    Hive.registerAdapter(FilterModelAdapter());
  }
}
