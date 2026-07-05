import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';

enum TaskFormMode { create, edit }

sealed class TaskFormState extends Equatable {
  const TaskFormState();

  @override
  List<Object?> get props => [];
}

final class TaskFormInitial extends TaskFormState {
  const TaskFormInitial();
}

final class TaskFormLoading extends TaskFormState {
  const TaskFormLoading();
}

final class TaskFormReady extends TaskFormState {
  const TaskFormReady({
    required this.mode,
    required this.title,
    required this.description,
    required this.categoryId,
    this.dueDate,
    this.originalTask,
    this.titleError,
    this.isSubmitting = false,
  });

  final TaskFormMode mode;
  final String title;
  final String description;
  final String categoryId;
  final DateTime? dueDate;
  final Task? originalTask;
  final String? titleError;
  final bool isSubmitting;

  TaskFormReady copyWith({
    TaskFormMode? mode,
    String? title,
    String? description,
    String? categoryId,
    DateTime? dueDate,
    bool clearDueDate = false,
    Task? originalTask,
    String? titleError,
    bool clearTitleError = false,
    bool? isSubmitting,
  }) {
    return TaskFormReady(
      mode: mode ?? this.mode,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      originalTask: originalTask ?? this.originalTask,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        title,
        description,
        categoryId,
        dueDate,
        originalTask,
        titleError,
        isSubmitting,
      ];
}

final class TaskFormSuccess extends TaskFormState {
  const TaskFormSuccess();
}

final class TaskFormFailure extends TaskFormState {
  const TaskFormFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
