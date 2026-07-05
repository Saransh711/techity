import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Expandable FAB with fan-out actions and scrim dismiss.
class AnimatedFab extends StatefulWidget {
  const AnimatedFab({
    required this.onAddTask,
    required this.onFilterShortcut,
    super.key,
  });

  final VoidCallback onAddTask;
  final VoidCallback onFilterShortcut;

  @override
  State<AnimatedFab> createState() => AnimatedFabState();
}

class AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  OverlayEntry? _scrimEntry;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fabExpand,
      reverseDuration: AppDurations.fabCollapse,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _removeScrim();
    _controller.dispose();
    super.dispose();
  }

  void collapse() {
    if (!_isExpanded) {
      return;
    }
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isExpanded = false);
        _removeScrim();
      }
    });
  }

  void _toggle() {
    if (_isExpanded) {
      collapse();
    } else {
      setState(() => _isExpanded = true);
      _insertScrim();
      _controller.forward();
    }
  }

  void _insertScrim() {
    _scrimEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: FadeTransition(
            opacity: _expandAnimation,
            child: GestureDetector(
              onTap: collapse,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: AppColors.scrim),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_scrimEntry!);
  }

  void _removeScrim() {
    _scrimEntry?.remove();
    _scrimEntry = null;
  }

  void _runAction(VoidCallback action) {
    collapse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isExpanded,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isExpanded) {
          collapse();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: _expandAnimation.value.clamp(0, 1),
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _FabAction(
                  animation: _expandAnimation,
                  delay: 0.15,
                  label: AppStrings.filterToday,
                  icon: Icons.filter_alt_outlined,
                  onPressed: () => _runAction(widget.onFilterShortcut),
                ),
                AppSpacing.itemGap,
                _FabAction(
                  animation: _expandAnimation,
                  delay: 0.08,
                  label: AppStrings.addTask,
                  icon: Icons.add_task_outlined,
                  onPressed: () => _runAction(widget.onAddTask),
                ),
                AppSpacing.sectionGap,
              ],
            ),
          ),
          FloatingActionButton(
            onPressed: _toggle,
            tooltip: _isExpanded ? AppStrings.close : AppStrings.addTask,
            child: RotationTransition(
              turns: Tween<double>(
                begin: 0,
                end: 0.125,
              ).animate(_expandAnimation),
              child: AnimatedSwitcher(
                duration: AppDurations.fabCollapse,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  key: ValueKey(_isExpanded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FabAction extends StatelessWidget {
  const _FabAction({
    required this.animation,
    required this.delay,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final Animation<double> animation;
  final double delay;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delayedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(delayedAnimation),
        child: ScaleTransition(
          scale: delayedAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                elevation: AppSpacing.xs,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(label, style: theme.textTheme.labelLarge),
                ),
              ),
              AppSpacing.horizontalGapSm,
              FloatingActionButton.small(
                heroTag: label,
                onPressed: onPressed,
                tooltip: label,
                child: Icon(icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
