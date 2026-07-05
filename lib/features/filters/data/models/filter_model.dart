import 'package:hive/hive.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/active_filters.dart';

/// Hive persistence model for [ActiveFilters].
class FilterModel {
  const FilterModel({
    this.categoryId,
    this.status = TaskStatusFilter.all,
    this.dueDateFilter = DueDateFilter.all,
    this.dueDateStart,
    this.dueDateEnd,
  });

  final String? categoryId;
  final TaskStatusFilter status;
  final DueDateFilter dueDateFilter;
  final DateTime? dueDateStart;
  final DateTime? dueDateEnd;

  factory FilterModel.fromEntity(ActiveFilters filters) {
    return FilterModel(
      categoryId: filters.categoryId,
      status: filters.status,
      dueDateFilter: filters.dueDateFilter,
      dueDateStart: filters.dueDateStart,
      dueDateEnd: filters.dueDateEnd,
    );
  }

  ActiveFilters toEntity() {
    return ActiveFilters(
      categoryId: categoryId,
      status: status,
      dueDateFilter: dueDateFilter,
      dueDateStart: dueDateStart,
      dueDateEnd: dueDateEnd,
    );
  }
}

class FilterModelAdapter extends TypeAdapter<FilterModel> {
  @override
  final int typeId = AppKeys.filterStateTypeId;

  @override
  FilterModel read(BinaryReader reader) {
    return FilterModel(
      categoryId: _readOptionalString(reader),
      status: TaskStatusFilter.values[reader.readInt()],
      dueDateFilter: DueDateFilter.values[reader.readInt()],
      dueDateStart: _readOptionalDate(reader),
      dueDateEnd: _readOptionalDate(reader),
    );
  }

  @override
  void write(BinaryWriter writer, FilterModel obj) {
    _writeOptionalString(writer, obj.categoryId);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.dueDateFilter.index);
    _writeOptionalDate(writer, obj.dueDateStart);
    _writeOptionalDate(writer, obj.dueDateEnd);
  }

  String? _readOptionalString(BinaryReader reader) {
    final hasValue = reader.readBool();
    return hasValue ? reader.readString() : null;
  }

  void _writeOptionalString(BinaryWriter writer, String? value) {
    writer.writeBool(value != null);
    if (value != null) {
      writer.writeString(value);
    }
  }

  DateTime? _readOptionalDate(BinaryReader reader) {
    final hasValue = reader.readBool();
    if (!hasValue) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  void _writeOptionalDate(BinaryWriter writer, DateTime? value) {
    writer.writeBool(value != null);
    if (value != null) {
      writer.writeInt(value.millisecondsSinceEpoch);
    }
  }
}
