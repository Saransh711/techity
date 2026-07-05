import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/active_filters.dart';
import '../repositories/filter_repository.dart';

class SaveActiveFiltersParams extends Equatable {
  const SaveActiveFiltersParams({required this.filters});

  final ActiveFilters filters;

  @override
  List<Object?> get props => [filters];
}

class SaveActiveFilters {
  const SaveActiveFilters(this._repository);

  final FilterRepository _repository;

  Future<Either<Failure, void>> call(SaveActiveFiltersParams params) {
    return _repository.saveActiveFilters(params.filters);
  }
}
