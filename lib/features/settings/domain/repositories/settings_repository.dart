import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_theme_preference.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppThemePreference>> getThemePreference();

  Future<Either<Failure, void>> saveThemePreference(
    AppThemePreference preference,
  );
}
