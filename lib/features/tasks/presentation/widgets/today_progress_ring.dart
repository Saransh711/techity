import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/today_completion_stats.dart';

/// Animated circular progress ring for today's task completion.
class TodayProgressRing extends StatefulWidget {
  const TodayProgressRing({
    required this.stats,
    this.forSliverHeader = false,
    super.key,
  });

  final TodayCompletionStats stats;
  final bool forSliverHeader;

  static const ringSize = AppSpacing.xxl + AppSpacing.xl;
  static const strokeWidth = AppSpacing.sm;

  @override
  State<TodayProgressRing> createState() => _TodayProgressRingState();
}

class _TodayProgressRingState extends State<TodayProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _displayedProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.progressRing,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.stats.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _displayedProgress = widget.stats.progress;
  }

  @override
  void didUpdateWidget(TodayProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats.progress != widget.stats.progress) {
      _progressAnimation =
          Tween<double>(
            begin: _displayedProgress,
            end: widget.stats.progress,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
      _displayedProgress = widget.stats.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (widget.stats.progress * 100).round();

    final content = Row(
      children: [
        SizedBox(
          width: TodayProgressRing.ringSize,
          height: TodayProgressRing.ringSize,
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _ProgressRingPainter(
                  progress: _progressAnimation.value,
                  trackColor: theme.colorScheme.surfaceContainerHighest,
                  progressColor: theme.colorScheme.primary,
                  strokeWidth: TodayProgressRing.strokeWidth,
                ),
                child: Center(
                  child: Text(
                    '$percent%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AppSpacing.horizontalGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.todayProgress,
                style: theme.textTheme.titleSmall,
              ),
              AppSpacing.itemGap,
              Text(
                AppStrings.todayProgressDetail(
                  widget.stats.completedCount,
                  widget.stats.totalCount,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.forSliverHeader) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: content,
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0, 1),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
