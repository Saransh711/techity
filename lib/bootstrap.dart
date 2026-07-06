import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/usecases/no_params.dart';
import 'features/reminders/domain/usecases/initialize_task_reminders.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/domain/entities/app_theme_preference.dart';
import 'features/settings/presentation/utils/theme_mode_mapper.dart';
import 'features/tasks/data/hive/hive_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await initializeHiveStorage(getIt);
  configureDependencies();

  await getIt<InitializeTaskReminders>()(const NoParams());

  final initialPreference =
      getIt<SettingsLocalDataSource>().readThemePreferenceSync() ??
      AppThemePreference.system;
  final initialThemeMode = ThemeModeMapper.toThemeMode(initialPreference);

  runApp(
    App(
      initialThemeMode: initialThemeMode,
      initialThemePreference: initialPreference,
    ),
  );
}
