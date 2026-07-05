import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';

/// Empty task list placeholder.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_outlined,
              size: AppSpacing.xxl * 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            AppSpacing.sectionGap,
            Text(
              AppStrings.noTasks,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.itemGap,
            Text(
              AppStrings.noTasksSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
