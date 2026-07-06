import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../categories/domain/entities/task_category.dart';
import '../../../filters/domain/entities/active_filters.dart';
import '../../../filters/presentation/widgets/task_filter_bar.dart';
import '../../../settings/presentation/widgets/theme_toggle_button.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/today_completion_stats.dart';
import '../../../tasks/presentation/bloc/task_list_bloc.dart';
import '../../../tasks/presentation/bloc/task_list_event.dart';
import '../../../tasks/presentation/bloc/task_list_state.dart';
import '../../../tasks/presentation/widgets/animated_fab.dart';
import '../../../tasks/presentation/widgets/empty_state_widget.dart';
import '../../../tasks/presentation/widgets/home_task_search_anchor.dart';
import '../../../tasks/presentation/widgets/today_progress_ring.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import '../../../tasks/presentation/widgets/undo_snackbar_content.dart';
import '../../../reminders/domain/usecases/request_reminder_permissions.dart';

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

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  static const _fabSize = 56.0;

  @override
  void initState() {
    super.initState();
    _requestReminderPermissions();
  }

  Future<void> _requestReminderPermissions() async {
    await getIt<RequestReminderPermissions>()(const NoParams());
  }

  Future<void> _openTaskForm(BuildContext context, {String? taskId}) async {
    final saved = await AppRouter.pushTaskForm(context, taskId: taskId);
    if (saved == true && context.mounted) {
      context.read<TaskListBloc>().add(const RefreshTasksRequested());
    }
  }

  void _applyTodayFilter(BuildContext context) {
    final bloc = context.read<TaskListBloc>();
    final state = bloc.state;
    if (state is! TaskListLoaded) {
      return;
    }

    bloc.add(
      ApplyFiltersRequested(
        state.activeFilters.copyWith(
          dueDateFilter: DueDateFilter.today,
          clearCustomDueDate: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          BlocConsumer<TaskListBloc, TaskListState>(
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
                      onPressed: () => context.read<TaskListBloc>().add(
                        const RestoreTaskRequested(),
                      ),
                    ),
                  ),
                );
            },
            builder: (context, state) {
              return switch (state) {
                TaskListInitial() || TaskListLoading() => NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _HomeSliverAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
                  ],
                  body: const Center(child: CircularProgressIndicator()),
                ),
                TaskListFailure(:final message) => NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _HomeSliverAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
                  ],
                  body: _TaskListError(
                    message: message,
                    onRetry: () => context.read<TaskListBloc>().add(
                      const LoadTasksRequested(),
                    ),
                  ),
                ),
                TaskListLoaded() => _TaskListContent(fabClearance: _fabSize),
              };
            },
          ),
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
            child: AnimatedFab(
              onAddTask: () => _openTaskForm(context),
              onFilterShortcut: () => _applyTodayFilter(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSliverAppBar extends StatelessWidget {
  const _HomeSliverAppBar({required this.innerBoxIsScrolled});

  final bool innerBoxIsScrolled;

  static double get expandedHeight =>
      kToolbarHeight + TodayProgressRing.ringSize + AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background:
            BlocSelector<TaskListBloc, TaskListState, TodayCompletionStats>(
              selector: (state) => state is TaskListLoaded
                  ? state.todayProgress
                  : const TodayCompletionStats(
                      completedCount: 0,
                      totalCount: 0,
                    ),
              builder: (context, stats) =>
                  TodayProgressRing(stats: stats, forSliverHeader: true),
            ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppStrings.appTitle, style: theme.textTheme.titleLarge),
          if (innerBoxIsScrolled)
            BlocSelector<TaskListBloc, TaskListState, TodayCompletionStats>(
              selector: (state) => state is TaskListLoaded
                  ? state.todayProgress
                  : const TodayCompletionStats(
                      completedCount: 0,
                      totalCount: 0,
                    ),
              builder: (context, stats) {
                final percent = (stats.progress * 100).round();
                return Text(
                  AppStrings.todayProgressCompact(
                    stats.completedCount,
                    stats.totalCount,
                    percent,
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
        ],
      ),
      actions: [
        const HomeTaskSearchAnchor(),
        if (kDebugMode)
          IconButton(
            tooltip: AppStrings.debugSeedTasksTooltip,
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () => context.read<TaskListBloc>().add(
              const SeedDebugTasksRequested(),
            ),
          ),
        const ThemeToggleButton(),
      ],
    );
  }
}

class _TaskListContent extends StatelessWidget {
  const _TaskListContent({required this.fabClearance});

  final double fabClearance;

  TaskCategory _categoryFor(String categoryId) {
    return TaskCategory.defaults.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => TaskCategory.defaults.first,
    );
  }

  Future<void> _openTaskForm(
    BuildContext context, {
    required String taskId,
  }) async {
    final saved = await AppRouter.pushTaskForm(context, taskId: taskId);
    if (saved == true && context.mounted) {
      context.read<TaskListBloc>().add(const RefreshTasksRequested());
    }
  }

  void _onReorder(
    BuildContext context,
    List<Task> visibleTasks,
    int oldIndex,
    int newIndex,
  ) {
    final reordered = List<Task>.from(visibleTasks);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    context.read<TaskListBloc>().add(
      ReorderTasksRequested(
        reordered.map((task) => task.id).toList(growable: false),
      ),
    );
  }

  double _listBottomPadding(BuildContext context) {
    return AppSpacing.lg + fabClearance + MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _HomeSliverAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
        SliverToBoxAdapter(
          child: BlocSelector<TaskListBloc, TaskListState, ActiveFilters>(
            selector: (state) => state is TaskListLoaded
                ? state.activeFilters
                : ActiveFilters.empty,
            builder: (context, activeFilters) {
              final bloc = context.read<TaskListBloc>();
              return TaskFilterBar(
                activeFilters: activeFilters,
                onFiltersChanged: (filters) =>
                    bloc.add(ApplyFiltersRequested(filters)),
                onClearFilters: () => bloc.add(const ClearFiltersRequested()),
              );
            },
          ),
        ),
      ],
      body: BlocSelector<TaskListBloc, TaskListState, _VisibleTaskListData>(
        selector: (state) {
          if (state is TaskListLoaded) {
            return _VisibleTaskListData(
              visibleTasks: state.visibleTasks,
              reorderEnabled: state.pendingDelete == null,
              isEmptyDueToFilters:
                  state.visibleTasks.isEmpty &&
                  state.allTasks.isNotEmpty &&
                  state.activeFilters.hasActiveFilters,
            );
          }
          return const _VisibleTaskListData.empty();
        },
        builder: (context, data) {
          if (data.visibleTasks.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(bottom: _listBottomPadding(context)),
              child: EmptyStateWidget(
                variant: data.isEmptyDueToFilters
                    ? EmptyStateVariant.noFilterResults
                    : EmptyStateVariant.noTasks,
                onClearFilters: data.isEmptyDueToFilters
                    ? () => context.read<TaskListBloc>().add(
                        const ClearFiltersRequested(),
                      )
                    : null,
              ),
            );
          }

          final bloc = context.read<TaskListBloc>();

          return ReorderableListView.builder(
            primary: false,
            padding: EdgeInsets.only(bottom: _listBottomPadding(context)),
            itemCount: data.visibleTasks.length,
            onReorderItem: (oldIndex, newIndex) {
              if (!data.reorderEnabled) return;
              _onReorder(context, data.visibleTasks, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final task = data.visibleTasks[index];
              return Dismissible(
                key: ValueKey(task.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  bloc.add(DeleteTaskRequested(task.id));
                  final nextState = await bloc.stream.firstWhere(
                    (state) =>
                        state is TaskListLoaded &&
                        state.pendingDelete?.id == task.id,
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
                  onToggleComplete: () =>
                      bloc.add(ToggleTaskCompleteRequested(task.id)),
                  onTap: () => _openTaskForm(context, taskId: task.id),
                  dragHandle: data.reorderEnabled
                      ? ReorderableDragStartListener(
                          index: index,
                          child: Tooltip(
                            message: AppStrings.reorderTasks,
                            child: Icon(
                              Icons.drag_handle,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VisibleTaskListData extends Equatable {
  const _VisibleTaskListData({
    required this.visibleTasks,
    required this.reorderEnabled,
    required this.isEmptyDueToFilters,
  });

  const _VisibleTaskListData.empty()
    : visibleTasks = const [],
      reorderEnabled = false,
      isEmptyDueToFilters = false;

  final List<Task> visibleTasks;
  final bool reorderEnabled;
  final bool isEmptyDueToFilters;

  @override
  List<Object?> get props => [
    visibleTasks,
    reorderEnabled,
    isEmptyDueToFilters,
  ];
}

class _TaskListError extends StatelessWidget {
  const _TaskListError({required this.message, required this.onRetry});

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
