import 'package:flutter/material.dart' hide DateUtils;

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/task_category.dart';
import '../../domain/entities/task.dart';
import 'category_chip.dart';

/// Single row in the task list.
class TaskListItem extends StatelessWidget {
  const TaskListItem({
    required this.task,
    required this.category,
    required this.onToggleComplete,
    required this.onTap,
    this.dragHandle,
    super.key,
  });

  final Task task;
  final TaskCategory category;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: AppSpacing.listItemPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggleComplete(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      AppSpacing.itemGap,
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    AppSpacing.itemGap,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CategoryChip(category: category),
                        if (task.dueDate != null)
                          _DueDateLabel(dueDate: task.dueDate!),
                      ],
                    ),
                  ],
                ),
              ),
              if (dragHandle != null) ...[
                AppSpacing.horizontalGapSm,
                dragHandle!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DueDateLabel extends StatelessWidget {
  const _DueDateLabel({required this.dueDate});

  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = DateUtils.isOverdue(dueDate);
    final isToday = DateUtils.isToday(dueDate);

    final color = isOverdue
        ? theme.colorScheme.error
        : isToday
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 14, color: color),
        AppSpacing.horizontalGapSm,
        Text(
          DateUtils.formatDueDate(dueDate),
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
