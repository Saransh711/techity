import 'package:equatable/equatable.dart';

sealed class TaskFormEvent extends Equatable {
  const TaskFormEvent();

  @override
  List<Object?> get props => [];
}

final class TaskFormInitialized extends TaskFormEvent {
  const TaskFormInitialized();
}

final class TaskFormLoadRequested extends TaskFormEvent {
  const TaskFormLoadRequested(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

final class TaskFormTitleChanged extends TaskFormEvent {
  const TaskFormTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class TaskFormDescriptionChanged extends TaskFormEvent {
  const TaskFormDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class TaskFormCategoryChanged extends TaskFormEvent {
  const TaskFormCategoryChanged(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class TaskFormDueDateChanged extends TaskFormEvent {
  const TaskFormDueDateChanged(this.dueDate);

  final DateTime? dueDate;

  @override
  List<Object?> get props => [dueDate];
}

final class TaskFormSubmitRequested extends TaskFormEvent {
  const TaskFormSubmitRequested();
}
