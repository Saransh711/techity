import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';
import '../../../categories/domain/entities/task_category.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/get_task_by_id.dart';
import '../../domain/usecases/update_task.dart';
import 'task_form_event.dart';
import 'task_form_state.dart';

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  TaskFormBloc({
    required this._getTaskById,
    required this._createTask,
    required this._updateTask,
    String? taskId,
  }) : super(const TaskFormInitial()) {
    on<TaskFormInitialized>(_onInitialized);
    on<TaskFormLoadRequested>(_onLoadRequested);
    on<TaskFormTitleChanged>(_onTitleChanged);
    on<TaskFormDescriptionChanged>(_onDescriptionChanged);
    on<TaskFormCategoryChanged>(_onCategoryChanged);
    on<TaskFormDueDateChanged>(_onDueDateChanged);
    on<TaskFormSubmitRequested>(_onSubmitRequested);

    if (taskId != null) {
      add(TaskFormLoadRequested(taskId));
    } else {
      add(const TaskFormInitialized());
    }
  }

  final GetTaskById _getTaskById;
  final CreateTask _createTask;
  final UpdateTask _updateTask;

  void _onInitialized(TaskFormInitialized event, Emitter<TaskFormState> emit) {
    emit(
      TaskFormReady(
        mode: TaskFormMode.create,
        title: '',
        description: '',
        categoryId: TaskCategory.defaults.first.id,
      ),
    );
  }

  Future<void> _onLoadRequested(
    TaskFormLoadRequested event,
    Emitter<TaskFormState> emit,
  ) async {
    emit(const TaskFormLoading());

    final result = await _getTaskById(GetTaskByIdParams(id: event.taskId));

    result.fold(
      (failure) => emit(TaskFormFailure(failure.message)),
      (task) => emit(
        TaskFormReady(
          mode: TaskFormMode.edit,
          title: task.title,
          description: task.description,
          categoryId: task.categoryId,
          dueDate: task.dueDate,
          originalTask: task,
        ),
      ),
    );
  }

  void _onTitleChanged(
    TaskFormTitleChanged event,
    Emitter<TaskFormState> emit,
  ) {
    final current = state;
    if (current is! TaskFormReady) {
      return;
    }

    emit(current.copyWith(title: event.title, clearTitleError: true));
  }

  void _onDescriptionChanged(
    TaskFormDescriptionChanged event,
    Emitter<TaskFormState> emit,
  ) {
    final current = state;
    if (current is! TaskFormReady) {
      return;
    }

    emit(current.copyWith(description: event.description));
  }

  void _onCategoryChanged(
    TaskFormCategoryChanged event,
    Emitter<TaskFormState> emit,
  ) {
    final current = state;
    if (current is! TaskFormReady) {
      return;
    }

    emit(current.copyWith(categoryId: event.categoryId));
  }

  void _onDueDateChanged(
    TaskFormDueDateChanged event,
    Emitter<TaskFormState> emit,
  ) {
    final current = state;
    if (current is! TaskFormReady) {
      return;
    }

    emit(
      current.copyWith(
        dueDate: event.dueDate,
        clearDueDate: event.dueDate == null,
      ),
    );
  }

  Future<void> _onSubmitRequested(
    TaskFormSubmitRequested event,
    Emitter<TaskFormState> emit,
  ) async {
    final current = state;
    if (current is! TaskFormReady || current.isSubmitting) {
      return;
    }

    final trimmedTitle = current.title.trim();
    if (trimmedTitle.isEmpty) {
      emit(
        current.copyWith(
          titleError: const ValidationFailure(
            AppStrings.errorTitleRequired,
          ).message,
        ),
      );
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearTitleError: true));

    if (current.mode == TaskFormMode.create) {
      final result = await _createTask(
        CreateTaskParams(
          title: trimmedTitle,
          description: current.description.trim(),
          categoryId: current.categoryId,
          dueDate: current.dueDate,
        ),
      );

      result.fold((failure) {
        if (failure is ValidationFailure) {
          emit(
            current.copyWith(isSubmitting: false, titleError: failure.message),
          );
        } else {
          emit(TaskFormFailure(failure.message));
        }
      }, (_) => emit(const TaskFormSuccess()));
    } else {
      final original = current.originalTask;
      if (original == null) {
        emit(const TaskFormFailure(AppStrings.errorSaveTask));
        return;
      }

      final updated = original.copyWith(
        title: trimmedTitle,
        description: current.description.trim(),
        categoryId: current.categoryId,
        dueDate: current.dueDate,
        clearDueDate: current.dueDate == null,
        updatedAt: DateTime.now(),
      );

      final result = await _updateTask(UpdateTaskParams(task: updated));

      result.fold((failure) {
        if (failure is ValidationFailure) {
          emit(
            current.copyWith(isSubmitting: false, titleError: failure.message),
          );
        } else {
          emit(TaskFormFailure(failure.message));
        }
      }, (_) => emit(const TaskFormSuccess()));
    }
  }
}
