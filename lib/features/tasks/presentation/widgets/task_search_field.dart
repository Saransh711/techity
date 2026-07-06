import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import 'task_search_debouncer.dart';

/// Debounced search input for filtering tasks by title and description.
class TaskSearchField extends StatefulWidget {
  const TaskSearchField({
    required this.initialQuery,
    required this.onSearchChanged,
    super.key,
  });

  final String initialQuery;
  final ValueChanged<String> onSearchChanged;

  @override
  State<TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends State<TaskSearchField> {
  late final TextEditingController _controller;
  late final TaskSearchDebouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _debouncer = TaskSearchDebouncer(onSearchChanged: widget.onSearchChanged);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(TaskSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery &&
        widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) => _debouncer.onChanged(value);

  void _clear() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: SearchBar(
        hintText: AppStrings.searchTasks,
        leading: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
        trailing: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: AppStrings.clearSearch,
              icon: const Icon(Icons.close),
              onPressed: _clear,
            ),
        ],
        controller: _controller,
        onChanged: _onChanged,
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
