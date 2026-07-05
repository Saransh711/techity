import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/task_list_bloc.dart';
import '../bloc/task_list_state.dart';

/// SnackBar content that shows a live undo countdown from [TaskListBloc].
class UndoSnackBarContent extends StatelessWidget {
  const UndoSnackBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListBloc, TaskListState>(
      buildWhen: (previous, current) =>
          current is TaskListLoaded &&
          current.pendingDelete != null &&
          (previous is! TaskListLoaded ||
              previous.undoSecondsRemaining !=
                  current.undoSecondsRemaining),
      builder: (context, state) {
        final seconds = state is TaskListLoaded
            ? state.undoSecondsRemaining
            : AppDurations.undoCountdownSeconds;

        return Text(
          '${AppStrings.taskDeleted} ${AppStrings.undoCountdown(seconds)}',
        );
      },
    );
  }
}
