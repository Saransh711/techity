// Filter state is owned by [TaskListBloc] (not a separate FilterBloc).
//
// YAGNI: filters only affect the task list; a dedicated bloc would duplicate
// [ActiveFilters] in state and require cross-bloc sync on every task mutation.
// [ApplyFiltersRequested] and [ClearFiltersRequested] persist via
// [SaveActiveFilters] / [ClearFilters] and re-apply via [TaskFilterUtils].
