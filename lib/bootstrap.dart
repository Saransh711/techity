import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/usecases/no_params.dart';
import 'features/settings/domain/usecases/get_theme_mode.dart';
import 'features/settings/presentation/utils/theme_mode_mapper.dart';
import 'features/tasks/data/hive/hive_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await initializeHiveStorage(getIt);
  configureDependencies();

  final themeResult = await getIt<GetThemeMode>()(const NoParams());
  final initialThemeMode = themeResult.fold(
    (_) => ThemeMode.system,
    ThemeModeMapper.toThemeMode,
  );

  runApp(App(initialThemeMode: initialThemeMode));
}
