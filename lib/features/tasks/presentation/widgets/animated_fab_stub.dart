import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Fixed-position FAB placeholder. Animated expand/collapse comes later.
// TODO: Implement animated expand/collapse FAB per assignment UX rules.
class AnimatedFabStub extends StatelessWidget {
  const AnimatedFabStub({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: AppStrings.addTask,
      child: const Icon(Icons.add),
    );
  }
}
