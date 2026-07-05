import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';

/// Distinguishes an empty task list from an empty filter result set.
enum EmptyStateVariant { noTasks, noFilterResults }

/// Empty task list or filter-result placeholder.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    this.variant = EmptyStateVariant.noTasks,
    this.onClearFilters,
    super.key,
  });

  final EmptyStateVariant variant;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFilterEmpty = variant == EmptyStateVariant.noFilterResults;

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFilterEmpty
                  ? Icons.filter_alt_off_outlined
                  : Icons.task_alt_outlined,
              size: AppSpacing.xxl * 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            AppSpacing.sectionGap,
            Text(
              isFilterEmpty ? AppStrings.noFilterResults : AppStrings.noTasks,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.itemGap,
            Text(
              isFilterEmpty
                  ? AppStrings.noFilterResultsSubtitle
                  : AppStrings.noTasksSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (isFilterEmpty && onClearFilters != null) ...[
              AppSpacing.sectionGap,
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text(AppStrings.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
