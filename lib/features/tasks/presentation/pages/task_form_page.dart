import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../categories/domain/entities/task_category.dart';
import '../bloc/task_form_bloc.dart';
import '../bloc/task_form_event.dart';
import '../bloc/task_form_state.dart';
import '../widgets/category_chip.dart';

/// Create or edit a task.
class TaskFormPage extends StatelessWidget {
  const TaskFormPage({this.taskId, super.key});

  final String? taskId;

  static final _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskFormBloc>(param1: taskId),
      child: const _TaskFormView(),
    );
  }
}

class _TaskFormView extends StatelessWidget {
  const _TaskFormView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskFormBloc, TaskFormState>(
      listenWhen: (previous, current) =>
          current is TaskFormSuccess || current is TaskFormFailure,
      listener: (context, state) {
        if (state is TaskFormSuccess) {
          AppRouter.pop(context, true);
        } else if (state is TaskFormFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isEdit =
            state is TaskFormReady && state.mode == TaskFormMode.edit;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? AppStrings.editTask : AppStrings.addTask),
          ),
          body: switch (state) {
            TaskFormInitial() || TaskFormLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TaskFormReady() => _TaskFormBody(state: state),
            TaskFormSuccess() => const SizedBox.shrink(),
            TaskFormFailure(:final message) => _TaskFormError(
              message: message,
              onRetry: () =>
                  context.read<TaskFormBloc>().add(const TaskFormInitialized()),
            ),
          },
          bottomNavigationBar: state is TaskFormReady
              ? SafeArea(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: FilledButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.read<TaskFormBloc>().add(
                              const TaskFormSubmitRequested(),
                            ),
                      child: state.isSubmitting
                          ? SizedBox(
                              height: theme.textTheme.labelLarge?.fontSize,
                              width: theme.textTheme.labelLarge?.fontSize,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(AppStrings.save),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _TaskFormBody extends StatefulWidget {
  const _TaskFormBody({required this.state});

  final TaskFormReady state;

  @override
  State<_TaskFormBody> createState() => _TaskFormBodyState();
}

class _TaskFormBodyState extends State<_TaskFormBody> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.title);
    _descriptionController = TextEditingController(
      text: widget.state.description,
    );
  }

  @override
  void didUpdateWidget(covariant _TaskFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.originalTask?.id != widget.state.originalTask?.id) {
      _titleController.text = widget.state.title;
      _descriptionController.text = widget.state.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<TaskFormBloc>();
    final state = widget.state;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: AppStrings.taskTitle,
            errorText: state.titleError,
          ),
          onChanged: (value) => bloc.add(TaskFormTitleChanged(value)),
        ),
        AppSpacing.sectionGap,
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: AppStrings.taskDescription,
          ),
          maxLines: 4,
          onChanged: (value) => bloc.add(TaskFormDescriptionChanged(value)),
        ),
        AppSpacing.sectionGap,
        Text(AppStrings.taskCategory, style: theme.textTheme.titleSmall),
        AppSpacing.itemGap,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in TaskCategory.defaults)
              CategoryChip(
                category: category,
                selected: state.categoryId == category.id,
                onTap: () => bloc.add(TaskFormCategoryChanged(category.id)),
              ),
          ],
        ),
        AppSpacing.sectionGap,
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.taskDueDate),
          subtitle: Text(
            state.dueDate == null
                ? AppStrings.noDueDate
                : TaskFormPage._dateFormat.format(state.dueDate!),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.dueDate != null)
                IconButton(
                  tooltip: AppStrings.cancel,
                  onPressed: () => bloc.add(const TaskFormDueDateChanged(null)),
                  icon: const Icon(Icons.clear),
                ),
              IconButton(
                tooltip: AppStrings.taskDueDate,
                onPressed: () => _pickDueDate(context, bloc, state.dueDate),
                icon: const Icon(Icons.calendar_today_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDueDate(
    BuildContext context,
    TaskFormBloc bloc,
    DateTime? current,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && context.mounted) {
      bloc.add(TaskFormDueDateChanged(picked));
    }
  }
}

class _TaskFormError extends StatelessWidget {
  const _TaskFormError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            AppSpacing.sectionGap,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
