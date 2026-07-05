import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/no_params.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/usecases/get_theme_mode.dart';
import '../../domain/usecases/save_theme_mode.dart';
import '../utils/theme_mode_mapper.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    required this._getThemeMode,
    required this._saveThemeMode,
    required AppThemePreference initialPreference,
  })  : super(
          ThemeLoaded(
            preference: initialPreference,
            themeMode: ThemeModeMapper.toThemeMode(initialPreference),
          ),
        ) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  final GetThemeMode _getThemeMode;
  final SaveThemeMode _saveThemeMode;

  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final result = await _getThemeMode(const NoParams());

    result.fold(
      (failure) => emit(ThemeFailure(failure.message)),
      (preference) => emit(
        ThemeLoaded(
          preference: preference,
          themeMode: ThemeModeMapper.toThemeMode(preference),
        ),
      ),
    );
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final current = switch (state) {
      ThemeLoaded(preference: final preference) => preference,
      _ => AppThemePreference.system,
    };

    final nextPreference = _toggledPreference(current);
    final saveResult = await _saveThemeMode(
      SaveThemeModeParams(themeMode: nextPreference),
    );

    saveResult.fold(
      (failure) {
        // Keep the current theme visible when persistence fails.
        if (state is! ThemeLoaded) {
          emit(ThemeFailure(failure.message));
        }
      },
      (_) => emit(
        ThemeLoaded(
          preference: nextPreference,
          themeMode: ThemeModeMapper.toThemeMode(nextPreference),
        ),
      ),
    );
  }

  AppThemePreference _toggledPreference(AppThemePreference current) {
    final effectiveBrightness = switch (current) {
      AppThemePreference.light => Brightness.light,
      AppThemePreference.dark => Brightness.dark,
      AppThemePreference.system => WidgetsBinding
              .instance.platformDispatcher.platformBrightness,
    };

    return effectiveBrightness == Brightness.light
        ? AppThemePreference.dark
        : AppThemePreference.light;
  }
}
