import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../repositories/filter_repository.dart';

class ClearFilters {
  const ClearFilters(this._repository);

  final FilterRepository _repository;

  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.clearFilters();
  }
}
