import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<Either<Failure, AppThemePreference>> getThemePreference() async {
    try {
      final preference = await _dataSource.readThemePreference();
      return Right(preference ?? AppThemePreference.system);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, void>> saveThemePreference(
    AppThemePreference preference,
  ) async {
    try {
      await _dataSource.writeThemePreference(preference);
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
