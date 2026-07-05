import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../entities/active_filters.dart';
import '../repositories/filter_repository.dart';

class GetActiveFilters {
  const GetActiveFilters(this._repository);

  final FilterRepository _repository;

  Future<Either<Failure, ActiveFilters>> call(NoParams params) {
    return _repository.getActiveFilters();
  }
}
