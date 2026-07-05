import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/active_filters.dart';
import '../../domain/repositories/filter_repository.dart';
import '../datasources/filter_local_datasource.dart';

class FilterRepositoryImpl implements FilterRepository {
  const FilterRepositoryImpl(this._dataSource);

  final FilterLocalDataSource _dataSource;

  @override
  Future<Either<Failure, ActiveFilters>> getActiveFilters() async {
    try {
      final filters = await _dataSource.readActiveFilters();
      return Right(filters);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, void>> saveActiveFilters(ActiveFilters filters) async {
    try {
      await _dataSource.writeActiveFilters(filters);
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  Future<Either<Failure, void>> clearFilters() async {
    try {
      await _dataSource.clearActiveFilters();
      return const Right(null);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
