import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/task_list_bloc.dart';
import '../bloc/task_list_state.dart';

/// SnackBar content with live undo countdown and progress indicator.
class UndoSnackBarContent extends StatelessWidget {
  const UndoSnackBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListBloc, TaskListState>(
      buildWhen: (previous, current) =>
          current is TaskListLoaded &&
          current.pendingDelete != null &&
          (previous is! TaskListLoaded ||
              previous.undoSecondsRemaining != current.undoSecondsRemaining),
      builder: (context, state) {
        final seconds = state is TaskListLoaded
            ? state.undoSecondsRemaining
            : AppDurations.undoCountdownSeconds;

        final progress = seconds / AppDurations.undoCountdownSeconds;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${AppStrings.taskDeleted} ${AppStrings.undoCountdown(seconds)}',
            ),
            AppSpacing.itemGap,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: AppSpacing.xs,
              ),
            ),
          ],
        );
      },
    );
  }
}
