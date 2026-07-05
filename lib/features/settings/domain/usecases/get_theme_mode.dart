import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../entities/app_theme_preference.dart';
import '../repositories/settings_repository.dart';

class GetThemeMode {
  const GetThemeMode(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, AppThemePreference>> call(NoParams params) {
    return _repository.getThemePreference();
  }
}
