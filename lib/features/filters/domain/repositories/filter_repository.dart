import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/active_filters.dart';

abstract class FilterRepository {
  Future<Either<Failure, ActiveFilters>> getActiveFilters();

  Future<Either<Failure, void>> saveActiveFilters(ActiveFilters filters);

  Future<Either<Failure, void>> clearFilters();
}
