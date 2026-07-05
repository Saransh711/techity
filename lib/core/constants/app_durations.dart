/// Animation durations and undo countdown timing.
abstract final class AppDurations {
  static const fabExpand = Duration(milliseconds: 250);
  static const fabCollapse = Duration(milliseconds: 200);
  static const pageTransition = Duration(milliseconds: 300);
  static const swipeDismiss = Duration(milliseconds: 200);
  static const snackbarShort = Duration(seconds: 2);
  static const undoCountdown = Duration(seconds: 5);
  static const debounce = Duration(milliseconds: 300);
  static const progressRing = Duration(milliseconds: 600);

  static const undoCountdownSeconds = 5;
}
