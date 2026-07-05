import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/task_category.dart';
import '../../domain/entities/active_filters.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';

/// Horizontal filter bar: category, status, due date, and clear action.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    required this.activeFilters,
    required this.onFiltersChanged,
    required this.onClearFilters,
    super.key,
  });

  final ActiveFilters activeFilters;
  final ValueChanged<ActiveFilters> onFiltersChanged;
  final VoidCallback onClearFilters;

  static final _dateFormat = DateFormat.MMMd();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterSection(
          label: AppStrings.categories,
          child: _CategoryFilters(
            activeFilters: activeFilters,
            onFiltersChanged: onFiltersChanged,
          ),
        ),
        _FilterSection(
          label: AppStrings.filterStatus,
          child: _StatusFilters(
            activeFilters: activeFilters,
            onFiltersChanged: onFiltersChanged,
          ),
        ),
        _FilterSection(
          label: AppStrings.filterDueDate,
          child: _DueDateFilters(
            activeFilters: activeFilters,
            onFiltersChanged: onFiltersChanged,
            dateFormat: _dateFormat,
          ),
        ),
        if (activeFilters.hasActiveFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: Text(AppStrings.clearFilters),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AppSpacing.itemGap,
          child,
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  final ActiveFilters activeFilters;
  final ValueChanged<ActiveFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _FilterChoiceChip(
            label: AppStrings.filterAll,
            selected: activeFilters.categoryId == null,
            onSelected: () =>
                onFiltersChanged(activeFilters.copyWith(clearCategoryId: true)),
          ),
          for (final category in TaskCategory.defaults) ...[
            AppSpacing.horizontalGapSm,
            CategoryChip(
              category: category,
              selected: activeFilters.categoryId == category.id,
              onTap: () {
                final isSelected = activeFilters.categoryId == category.id;
                onFiltersChanged(
                  isSelected
                      ? activeFilters.copyWith(clearCategoryId: true)
                      : activeFilters.copyWith(categoryId: category.id),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  final ActiveFilters activeFilters;
  final ValueChanged<ActiveFilters> onFiltersChanged;

  static const _options = <TaskStatusFilter, String>{
    TaskStatusFilter.all: AppStrings.filterAll,
    TaskStatusFilter.pending: AppStrings.filterPending,
    TaskStatusFilter.completed: AppStrings.filterCompleted,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final entry in _options.entries) ...[
            _FilterChoiceChip(
              label: entry.value,
              selected: activeFilters.status == entry.key,
              onSelected: () =>
                  onFiltersChanged(activeFilters.copyWith(status: entry.key)),
            ),
            if (entry.key != TaskStatusFilter.completed)
              AppSpacing.horizontalGapSm,
          ],
        ],
      ),
    );
  }
}

class _DueDateFilters extends StatelessWidget {
  const _DueDateFilters({
    required this.activeFilters,
    required this.onFiltersChanged,
    required this.dateFormat,
  });

  final ActiveFilters activeFilters;
  final ValueChanged<ActiveFilters> onFiltersChanged;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final customLabel =
        activeFilters.dueDateFilter == DueDateFilter.custom &&
            activeFilters.dueDateStart != null
        ? dateFormat.format(activeFilters.dueDateStart!)
        : AppStrings.filterPickDate;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _FilterChoiceChip(
            label: AppStrings.filterAll,
            selected: activeFilters.dueDateFilter == DueDateFilter.all,
            onSelected: () => onFiltersChanged(
              activeFilters.copyWith(
                dueDateFilter: DueDateFilter.all,
                clearCustomDueDate: true,
              ),
            ),
          ),
          AppSpacing.horizontalGapSm,
          _FilterChoiceChip(
            label: AppStrings.filterToday,
            selected: activeFilters.dueDateFilter == DueDateFilter.today,
            onSelected: () => onFiltersChanged(
              activeFilters.copyWith(
                dueDateFilter: DueDateFilter.today,
                clearCustomDueDate: true,
              ),
            ),
          ),
          AppSpacing.horizontalGapSm,
          _FilterChoiceChip(
            label: AppStrings.filterOverdue,
            selected: activeFilters.dueDateFilter == DueDateFilter.overdue,
            onSelected: () => onFiltersChanged(
              activeFilters.copyWith(
                dueDateFilter: DueDateFilter.overdue,
                clearCustomDueDate: true,
              ),
            ),
          ),
          AppSpacing.horizontalGapSm,
          _FilterChoiceChip(
            label: customLabel,
            selected: activeFilters.dueDateFilter == DueDateFilter.custom,
            onSelected: () => _pickCustomDate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = activeFilters.dueDateStart ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !context.mounted) {
      return;
    }

    final day = DateUtils.startOfDay(picked);
    onFiltersChanged(
      activeFilters.copyWith(
        dueDateFilter: DueDateFilter.custom,
        dueDateStart: day,
        dueDateEnd: day,
      ),
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  const _FilterChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
      ),
      selectedColor: theme.colorScheme.primaryContainer,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
        width: selected ? 1.5 : 1,
      ),
    );
  }
}
