import 'package:hive/hive.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/task.dart';

/// Hive persistence model for [Task].
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.categoryId,
    required super.isCompleted,
    required super.sortIndex,
    required super.createdAt,
    required super.updatedAt,
    super.dueDate,
    super.completedAt,
  });

  factory TaskModel.fromEntity(Task task) {
    if (task is TaskModel) {
      return task;
    }
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      categoryId: task.categoryId,
      isCompleted: task.isCompleted,
      sortIndex: task.sortIndex,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
    );
  }

  Task toEntity() => this;

  TaskModel copyWithModel({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    bool? isCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
    int? sortIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskModel.fromEntity(
      copyWith(
        id: id,
        title: title,
        description: description,
        categoryId: categoryId,
        isCompleted: isCompleted,
        dueDate: dueDate,
        clearDueDate: clearDueDate,
        sortIndex: sortIndex,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        clearCompletedAt: clearCompletedAt,
      ),
    );
  }
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = AppKeys.taskTypeId;

  @override
  TaskModel read(BinaryReader reader) {
    return TaskModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      categoryId: reader.readString(),
      isCompleted: reader.readBool(),
      sortIndex: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      dueDate: _readOptionalDate(reader),
      completedAt: _readOptionalDate(reader),
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.categoryId);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.sortIndex);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    _writeOptionalDate(writer, obj.dueDate);
    _writeOptionalDate(writer, obj.completedAt);
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
