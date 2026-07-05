import 'package:hive/hive.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/app_theme_preference.dart';

abstract class SettingsLocalDataSource {
  Future<AppThemePreference?> readThemePreference();

  Future<void> writeThemePreference(AppThemePreference preference);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl({required this.settingsBox});

  final Box<dynamic> settingsBox;

  @override
  Future<AppThemePreference?> readThemePreference() async {
    final raw = settingsBox.get(AppKeys.themeModeKey) as String?;
    if (raw == null) {
      return null;
    }
    return AppThemePreference.values.byName(raw);
  }

  @override
  Future<void> writeThemePreference(AppThemePreference preference) async {
    await settingsBox.put(AppKeys.themeModeKey, preference.name);
  }
}
