import '../../domain/entities/task.dart';

/// Merges a drag within the visible (filtered) list into the global order.
abstract final class TaskReorderUtils {
  /// **Filtered reorder strategy**
  ///
  /// 1. Sort [allTasks] by current [Task.sortIndex] (global baseline).
  /// 2. Record index slots occupied by tasks whose ids appear in
  ///    [visibleTaskIdsInNewOrder] (the post-drag visible sequence).
  /// 3. Write the reordered visible tasks back into those same slots; hidden
  ///    tasks keep their absolute positions between visible items.
  /// 4. Return the merged id list — caller assigns contiguous sortIndex 0..n-1.
  ///
  /// With no active filters, visible ids equal the full list and this reduces
  /// to a straight reorder of every task.
  static List<String> mergeVisibleReorder({
    required List<Task> allTasks,
    required List<String> visibleTaskIdsInNewOrder,
  }) {
    final sorted = List<Task>.from(allTasks)
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    final visibleIdSet = visibleTaskIdsInNewOrder.toSet();
    final visibleSlots = <int>[];
    for (var index = 0; index < sorted.length; index++) {
      if (visibleIdSet.contains(sorted[index].id)) {
        visibleSlots.add(index);
      }
    }

    if (visibleSlots.length != visibleTaskIdsInNewOrder.length) {
      throw ArgumentError(
        'visibleTaskIdsInNewOrder must match currently visible tasks',
      );
    }

    final byId = {for (final task in sorted) task.id: task};
    final merged = List<Task>.from(sorted);
    for (var index = 0; index < visibleSlots.length; index++) {
      final taskId = visibleTaskIdsInNewOrder[index];
      merged[visibleSlots[index]] = byId[taskId]!;
    }

    return merged.map((task) => task.id).toList(growable: false);
  }
}
