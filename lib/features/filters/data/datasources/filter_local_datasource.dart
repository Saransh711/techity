import 'package:hive/hive.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/active_filters.dart';
import '../models/filter_model.dart';

abstract class FilterLocalDataSource {
  Future<ActiveFilters> readActiveFilters();

  Future<void> writeActiveFilters(ActiveFilters filters);

  Future<void> clearActiveFilters();
}

class FilterLocalDataSourceImpl implements FilterLocalDataSource {
  FilterLocalDataSourceImpl({required this.filtersBox});

  final Box<dynamic> filtersBox;

  @override
  Future<ActiveFilters> readActiveFilters() async {
    final stored = filtersBox.get(AppKeys.activeFilterKey);
    if (stored == null) {
      return ActiveFilters.empty;
    }
    if (stored is! FilterModel) {
      throw FormatException('Invalid filter payload in Hive box.');
    }
    return stored.toEntity();
  }

  @override
  Future<void> writeActiveFilters(ActiveFilters filters) async {
    await filtersBox.put(
      AppKeys.activeFilterKey,
      FilterModel.fromEntity(filters),
    );
  }

  @override
  Future<void> clearActiveFilters() async {
    await filtersBox.delete(AppKeys.activeFilterKey);
  }
}
