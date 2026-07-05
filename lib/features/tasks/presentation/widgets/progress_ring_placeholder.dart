import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/today_completion_stats.dart';

/// Placeholder for the animated today's progress ring (next iteration).
class ProgressRingPlaceholder extends StatelessWidget {
  const ProgressRingPlaceholder({
    required this.stats,
    super.key,
  });

  final TodayCompletionStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (stats.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.xxl + AppSpacing.lg,
            height: AppSpacing.xxl + AppSpacing.lg,
            child: CircularProgressIndicator(
              value: stats.totalCount == 0 ? 0 : stats.progress,
              strokeWidth: AppSpacing.xs,
            ),
          ),
          AppSpacing.horizontalGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.todayProgress,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
