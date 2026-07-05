import 'package:equatable/equatable.dart';

import '../../../../core/constants/category_constants.dart';

/// Fixed task category (Work, Personal, Urgent).
class TaskCategory extends Equatable {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final String id;
  final String name;

  /// Six-digit hex color including leading `#`, e.g. `#2563EB`.
  final String colorHex;

  static const work = TaskCategory(
    id: CategoryConstants.workId,
    name: CategoryConstants.workName,
    colorHex: CategoryConstants.workColorHex,
  );

  static const personal = TaskCategory(
    id: CategoryConstants.personalId,
    name: CategoryConstants.personalName,
    colorHex: CategoryConstants.personalColorHex,
  );

  static const urgent = TaskCategory(
    id: CategoryConstants.urgentId,
    name: CategoryConstants.urgentName,
    colorHex: CategoryConstants.urgentColorHex,
  );

  static const List<TaskCategory> defaults = [work, personal, urgent];

  @override
  List<Object?> get props => [id, name, colorHex];
}
