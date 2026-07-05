import 'package:equatable/equatable.dart';

/// Completion metrics for tasks due today.
class TodayCompletionStats extends Equatable {
  const TodayCompletionStats({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  /// Value in `[0.0, 1.0]`. Returns `0` when [totalCount] is zero.
  double get progress =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  @override
  List<Object?> get props => [completedCount, totalCount];
}
