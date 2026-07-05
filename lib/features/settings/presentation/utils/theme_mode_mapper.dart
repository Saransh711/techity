import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_preference.dart';

/// Maps between domain [AppThemePreference] and Flutter [ThemeMode].
abstract final class ThemeModeMapper {
  static ThemeMode toThemeMode(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system => ThemeMode.system,
    };
  }

  static AppThemePreference fromThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => AppThemePreference.light,
      ThemeMode.dark => AppThemePreference.dark,
      ThemeMode.system => AppThemePreference.system,
    };
  }
}
