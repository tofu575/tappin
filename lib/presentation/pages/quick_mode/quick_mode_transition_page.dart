import 'package:flutter/material.dart';

import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_direction.dart';

const _transitionDuration = Duration(milliseconds: 750);

/// 同じ移動キャラクターを横切らせ、Quick Modeへの出入りを表現する。
class QuickModeTransitionPage extends StatefulWidget {
  const QuickModeTransitionPage({
    super.key,
    required this.direction,
    required this.character,
    required this.onCompleted,
  });

  final QuickModeTransitionDirection direction;
  final QuickModeCharacter character;
  final ValueChanged<BuildContext> onCompleted;

  @override
  State<QuickModeTransitionPage> createState() =>
      _QuickModeTransitionPageState();
}

class _QuickModeTransitionPageState extends State<QuickModeTransitionPage>
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
    final entering = widget.direction == QuickModeTransitionDirection.entering;

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
                  child: Text(
                    widget.character.emoji,
                    key: const Key('quick-mode-transition-character'),
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.48),
                  child: Text(
                    entering ? 'Quick Mode' : 'ホームへ戻ります',
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
