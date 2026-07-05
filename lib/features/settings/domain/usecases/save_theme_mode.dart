import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_theme_preference.dart';
import '../repositories/settings_repository.dart';

class SaveThemeModeParams extends Equatable {
  const SaveThemeModeParams({required this.themeMode});

  /// Domain theme preference (maps to Flutter [ThemeMode] in presentation).
  final AppThemePreference themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class SaveThemeMode {
  const SaveThemeMode(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(SaveThemeModeParams params) {
    return _repository.saveThemePreference(params.themeMode);
  }
}
