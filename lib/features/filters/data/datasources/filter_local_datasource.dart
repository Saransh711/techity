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
    final stored = filtersBox.get(AppKeys.activeFilterV2Key);
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
      AppKeys.activeFilterV2Key,
      FilterModel.fromEntity(filters),
    );
  }

  @override
  Future<void> clearActiveFilters() async {
    await filtersBox.delete(AppKeys.activeFilterV2Key);
  }
}

/// Drops legacy v1 filter payloads that used a single combined status enum.
Future<void> migrateFilterSchemaIfNeeded(Box<dynamic> filtersBox) async {
  if (filtersBox.containsKey(AppKeys.activeFilterV2Key)) {
    return;
  }
  if (filtersBox.containsKey(AppKeys.activeFilterKey)) {
    await filtersBox.delete(AppKeys.activeFilterKey);
  }
}
