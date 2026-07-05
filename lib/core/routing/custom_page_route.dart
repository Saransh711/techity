import 'package:flutter/material.dart';

import '../constants/app_durations.dart';

/// Custom page route with slide + fade transition.
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  CustomPageRoute({
    required this.page,
    super.settings,
  }) : super(
          transitionDuration: AppDurations.pageTransition,
          reverseTransitionDuration: AppDurations.pageTransition,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        );

  final Widget page;
}
