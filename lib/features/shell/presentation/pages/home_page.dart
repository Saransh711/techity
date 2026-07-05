import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../categories/domain/entities/task_category.dart';
import '../../../filters/presentation/widgets/task_filter_bar.dart';
import '../../../settings/presentation/widgets/theme_toggle_button.dart';
import '../../../tasks/presentation/bloc/task_list_bloc.dart';
import '../../../tasks/presentation/bloc/task_list_event.dart';
import '../../../tasks/presentation/bloc/task_list_state.dart';
import '../../../tasks/presentation/widgets/animated_fab_stub.dart';
import '../../../tasks/presentation/widgets/empty_state_widget.dart';
import '../../../tasks/presentation/widgets/progress_ring_placeholder.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import '../../../tasks/presentation/widgets/undo_snackbar_content.dart';

/// Home screen with task list, filters, and progress placeholder.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskListBloc>()..add(const LoadTasksRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _openTaskForm(BuildContext context, {String? taskId}) async {
    final saved = await AppRouter.pushTaskForm(
      context,
      taskId: taskId,
    );
    if (saved == true && context.mounted) {
      context.read<TaskListBloc>().add(const RefreshTasksRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appTitle,
          style: theme.textTheme.titleLarge,
        ),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      floatingActionButton: AnimatedFabStub(
        onPressed: () => _openTaskForm(context),
      ),
      body: BlocConsumer<TaskListBloc, TaskListState>(
        listenWhen: (previous, current) =>
            (current is TaskListLoaded &&
                current.pendingDelete != null &&
                (previous is! TaskListLoaded ||
                    previous.pendingDelete?.id !=
                        current.pendingDelete?.id)) ||
            (previous is TaskListLoaded &&
                previous.pendingDelete != null &&
                current is TaskListLoaded &&
                current.pendingDelete == null),
        listener: (context, state) {
          if (state is TaskListLoaded && state.pendingDelete == null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            return;
          }

          if (state is! TaskListLoaded || state.pendingDelete == null) {
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: AppDurations.undoCountdown,
                content: const UndoSnackBarContent(),
                action: SnackBarAction(
                  label: AppStrings.undo,
                  onPressed: () => context
                      .read<TaskListBloc>()
                      .add(const RestoreTaskRequested()),
                ),
              ),
            );
        },
        builder: (context, state) {
          return switch (state) {
            TaskListInitial() || TaskListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            TaskListFailure(:final message) => _TaskListError(
                message: message,
                onRetry: () => context
                    .read<TaskListBloc>()
                    .add(const LoadTasksRequested()),
              ),
            TaskListLoaded() => _TaskListContent(
                state: state,
                onEditTask: (taskId) => _openTaskForm(context, taskId: taskId),
              ),
          };
        },
      ),
    );
  }
}

class _TaskListContent extends StatelessWidget {
  const _TaskListContent({
    required this.state,
    required this.onEditTask,
  });

  final TaskListLoaded state;
  final ValueChanged<String> onEditTask;

  TaskCategory _categoryFor(String categoryId) {
    return TaskCategory.defaults.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => TaskCategory.defaults.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TaskListBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressRingPlaceholder(stats: state.todayProgress),
        TaskFilterBar(
          activeFilters: state.activeFilters,
          onFiltersChanged: (filters) => bloc.add(
            ApplyFiltersRequested(filters),
          ),
          onClearFilters: () => bloc.add(const ClearFiltersRequested()),
        ),
        Expanded(
          child: state.visibleTasks.isEmpty
              ? const EmptyStateWidget()
              : ListView.builder(
                  itemCount: state.visibleTasks.length,
                  itemBuilder: (context, index) {
                    final task = state.visibleTasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        bloc.add(DeleteTaskRequested(task.id));
                        final nextState = await bloc.stream.firstWhere(
                          (state) =>
                              state is TaskListLoaded &&
                              (state.pendingDelete?.id == task.id ||
                                  state.allTasks
                                      .every((item) => item.id != task.id)),
                        );
                        return nextState is TaskListLoaded;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: AppSpacing.pagePadding,
                        color: Theme.of(context).colorScheme.error,
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      child: TaskListItem(
                        task: task,
                        category: _categoryFor(task.categoryId),
                        onToggleComplete: () => bloc.add(
                          ToggleTaskCompleteRequested(task.id),
                        ),
                        onTap: () => onEditTask(task.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TaskListError extends StatelessWidget {
  const _TaskListError({
    required this.message,
    required this.onRetry,
  });

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
