import '../../../../core/constants/app_durations.dart';
import '../../../../core/utils/debouncer.dart';

/// Debounces task search input before notifying listeners.
class TaskSearchDebouncer {
  TaskSearchDebouncer({required this.onSearchChanged})
    : _debouncer = Debouncer(duration: AppDurations.debounce);

  final void Function(String query) onSearchChanged;
  final Debouncer _debouncer;

  void onChanged(String value) {
    _debouncer.run(() => onSearchChanged(value));
  }

  void dispose() => _debouncer.dispose();
}
