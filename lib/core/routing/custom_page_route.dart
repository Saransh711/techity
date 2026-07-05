import 'package:flutter/material.dart';

import '../constants/app_durations.dart';

/// Shared push/pop transition: slide from right + fade.
///
/// Push — incoming page enters from the right while fading in.
/// Pop — the reverse plays automatically via [PageRouteBuilder].
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  CustomPageRoute({required this.page, super.settings, super.fullscreenDialog})
    : super(
        transitionDuration: AppDurations.pageTransition,
        reverseTransitionDuration: AppDurations.pageTransition,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: _buildTransition,
      );

  final Widget page;

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slideIn = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(curved);

    final fadeIn = Tween<double>(begin: 0, end: 1).animate(curved);

    return SlideTransition(
      position: slideIn,
      child: FadeTransition(opacity: fadeIn, child: child),
    );
  }
}
