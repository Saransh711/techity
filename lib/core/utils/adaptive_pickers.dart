import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../../features/reminders/domain/utils/reminder_schedule_utils.dart';

/// Platform-native date and time pickers (Cupertino on iOS/macOS, Material elsewhere).
abstract final class AdaptivePickers {
  static bool _isCupertino(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  /// Picks a date only (no time component).
  static Future<DateTime?> pickDate(
    BuildContext context, {
    required DateTime initial,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 2);
    final last = lastDate ?? DateTime(now.year + 5);

    if (_isCupertino(context)) {
      return _pickCupertinoDate(
        context,
        initial: initial,
        firstDate: first,
        lastDate: last,
      );
    }

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
  }

  /// Picks a combined due date and time.
  static Future<DateTime?> pickDueDateTime(
    BuildContext context, {
    DateTime? initial,
  }) async {
    final now = DateTime.now();
    final current = initial ?? now;

    if (_isCupertino(context)) {
      return _pickCupertinoDateTime(context, initial: current);
    }

    return _pickMaterialDateTime(context, initial: current);
  }

  static Future<DateTime?> _pickMaterialDateTime(
    BuildContext context, {
    required DateTime initial,
  }) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null || !context.mounted) {
      return null;
    }

    final initialTime = _initialTimeOfDay(initial);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  static TimeOfDay _initialTimeOfDay(DateTime initial) {
    if (ReminderScheduleUtils.hasExplicitTime(initial)) {
      return TimeOfDay(hour: initial.hour, minute: initial.minute);
    }
    return const TimeOfDay(
      hour: ReminderScheduleUtils.defaultHour,
      minute: ReminderScheduleUtils.defaultMinute,
    );
  }

  static Future<DateTime?> _pickCupertinoDate(
    BuildContext context, {
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    var selected = initial;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (modalContext) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return CupertinoTheme(
          data: CupertinoTheme.of(context).copyWith(
            primaryColor: primaryColor,
          ),
          child: Container(
            height: 300,
            color: CupertinoColors.systemBackground.resolveFrom(modalContext),
            child: Column(
              children: [
                _CupertinoPickerHeader(
                  onCancel: () => Navigator.of(modalContext).pop(),
                  onDone: () => Navigator.of(modalContext).pop(selected),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: firstDate,
                    maximumDate: lastDate,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<DateTime?> _pickCupertinoDateTime(
    BuildContext context, {
    required DateTime initial,
  }) async {
    final now = DateTime.now();
    var selected = initial;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (modalContext) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return CupertinoTheme(
          data: CupertinoTheme.of(context).copyWith(
            primaryColor: primaryColor,
          ),
          child: Container(
            height: 300,
            color: CupertinoColors.systemBackground.resolveFrom(modalContext),
            child: Column(
              children: [
                _CupertinoPickerHeader(
                  onCancel: () => Navigator.of(modalContext).pop(),
                  onDone: () => Navigator.of(modalContext).pop(selected),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: initial,
                    minimumDate: DateTime(now.year - 1),
                    maximumDate: DateTime(now.year + 5),
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CupertinoPickerHeader extends StatelessWidget {
  const _CupertinoPickerHeader({
    required this.onCancel,
    required this.onDone,
  });

  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            onPressed: onCancel,
            child: Text(AppStrings.cancel),
          ),
          CupertinoButton(
            onPressed: onDone,
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
