import 'package:flutter/material.dart';

/// Spacing tokens on a 4/8/12/16/24 grid.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  static const pagePadding = EdgeInsets.all(lg);
  static const cardPadding = EdgeInsets.all(md);
  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );
  static const sectionGap = SizedBox(height: lg);
  static const itemGap = SizedBox(height: sm);
  static const horizontalGapSm = SizedBox(width: sm);
  static const horizontalGapMd = SizedBox(width: md);
}
