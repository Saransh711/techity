import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/task_list_bloc.dart';
import '../bloc/task_list_event.dart';
import '../bloc/task_list_state.dart';
import 'task_search_debouncer.dart';

/// AppBar search action that opens a full-width search view.
class HomeTaskSearchAnchor extends StatefulWidget {
  const HomeTaskSearchAnchor({super.key});

  @override
  State<HomeTaskSearchAnchor> createState() => _HomeTaskSearchAnchorState();
}

class _HomeTaskSearchAnchorState extends State<HomeTaskSearchAnchor> {
  late final SearchController _searchController;
  late final TaskSearchDebouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _debouncer = TaskSearchDebouncer(onSearchChanged: _dispatchSearch);
    _searchController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onControllerChanged);
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _dispatchSearch(String query) {
    context.read<TaskListBloc>().add(SearchQueryChanged(query));
  }

  void _syncQueryFromBloc(String query) {
    if (_searchController.text != query) {
      _searchController.text = query;
    }
  }

  void _clear() {
    _searchController.clear();
    _dispatchSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskListBloc, TaskListState>(
      listenWhen: (previous, current) {
        final previousQuery = previous is TaskListLoaded
            ? previous.activeFilters.searchQuery
            : '';
        final currentQuery = current is TaskListLoaded
            ? current.activeFilters.searchQuery
            : '';
        return previousQuery != currentQuery;
      },
      listener: (context, state) {
        if (state is TaskListLoaded) {
          _syncQueryFromBloc(state.activeFilters.searchQuery);
        }
      },
      child: BlocSelector<TaskListBloc, TaskListState, String>(
        selector: (state) => state is TaskListLoaded
            ? state.activeFilters.searchQuery
            : '',
        builder: (context, searchQuery) {
          return SearchAnchor(
            searchController: _searchController,
            viewHintText: AppStrings.searchTasks,
            viewOnChanged: _debouncer.onChanged,
            viewTrailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  tooltip: AppStrings.clearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                ),
            ],
            builder: (context, controller) {
              return IconButton(
                tooltip: AppStrings.searchTasks,
                onPressed: () => controller.openView(),
                icon: Badge(
                  isLabelVisible: searchQuery.isNotEmpty,
                  smallSize: AppSpacing.sm,
                  child: const Icon(Icons.search),
                ),
              );
            },
            suggestionsBuilder: (context, controller) => const [],
          );
        },
      ),
    );
  }
}
