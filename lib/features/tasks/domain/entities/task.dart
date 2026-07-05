import 'package:equatable/equatable.dart';

/// Core task entity. Pure Dart — no Hive or Flutter imports.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.isCompleted,
    required this.sortIndex,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final String categoryId;
  final bool isCompleted;
  final DateTime? dueDate;

  /// 0-based position in the ordered task list. Contiguous after every reorder.
  final int sortIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Task copyWith({
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
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      sortIndex: sortIndex ?? this.sortIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryId,
        isCompleted,
        dueDate,
        sortIndex,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
