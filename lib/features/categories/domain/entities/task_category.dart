import 'package:equatable/equatable.dart';

import '../../../../core/constants/category_constants.dart';

/// Fixed task category (Work, Personal, Urgent).
class TaskCategory extends Equatable {
  const TaskCategory({required this.id, required this.name});

  final String id;
  final String name;

  static const work = TaskCategory(
    id: CategoryConstants.workId,
    name: CategoryConstants.workName,
  );

  static const personal = TaskCategory(
    id: CategoryConstants.personalId,
    name: CategoryConstants.personalName,
  );

  static const urgent = TaskCategory(
    id: CategoryConstants.urgentId,
    name: CategoryConstants.urgentName,
  );

  static const List<TaskCategory> defaults = [work, personal, urgent];

  static TaskCategory? byId(String id) {
    for (final category in defaults) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [id, name];
}
