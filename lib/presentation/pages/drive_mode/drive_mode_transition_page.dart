import 'package:flutter/material.dart';

import 'package:tappin/presentation/pages/drive_mode/drive_transition_direction.dart';

const _transitionDuration = Duration(milliseconds: 750);

/// [direction]に応じて車を横切らせ、完了時に[onCompleted]へ遷移を引き継ぐ画面。
class DriveModeTransitionPage extends StatefulWidget {
  const DriveModeTransitionPage({
    super.key,
    required this.direction,
    required this.onCompleted,
  });

  final DriveTransitionDirection direction;
  final ValueChanged<BuildContext> onCompleted;

  @override
  State<DriveModeTransitionPage> createState() =>
      _DriveModeTransitionPageState();
}

class _DriveModeTransitionPageState extends State<DriveModeTransitionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _didComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    )..addStatusListener(_handleStatus);
    _controller.forward();
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _didComplete) return;
    _didComplete = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCompleted(context);
    });
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entering = widget.direction == DriveTransitionDirection.entering;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = Curves.easeInOut.transform(_controller.value);
          final horizontal = entering
              ? -1.35 + (2.7 * progress)
              : 1.35 - (2.7 * progress);
          final backgroundProgress = entering ? progress : 1 - progress;
          final backgroundColor = Color.lerp(
            colorScheme.surface,
            colorScheme.primaryContainer,
            backgroundProgress,
          );

          return ColoredBox(
            color: backgroundColor ?? colorScheme.surface,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment(horizontal, 0),
                  child: Icon(
                    Icons.directions_car_rounded,
                    key: const Key('drive-transition-car'),
                    size: 72,
                    color: colorScheme.primary,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.48),
                  child: Text(
                    entering ? 'Drive mode' : '通常モードへ戻ります',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
