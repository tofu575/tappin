import 'package:flutter/material.dart';

import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';

const _lapDuration = Duration(seconds: 6);

/// Quick Mode中、選ばれた移動キャラクターを穏やかに動かす。
class QuickModeCharacterLane extends StatefulWidget {
  const QuickModeCharacterLane({super.key, required this.character});

  final QuickModeCharacter character;

  @override
  State<QuickModeCharacterLane> createState() => _QuickModeCharacterLaneState();
}

class _QuickModeCharacterLaneState extends State<QuickModeCharacterLane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _lapDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('quick-mode-character-lane'),
      height: 44,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.easeInOut.transform(_controller.value);
            final horizontal = -40 + ((constraints.maxWidth + 80) * progress);
            final opacity = progress < 0.08
                ? progress / 0.08
                : progress > 0.92
                ? (1 - progress) / 0.08
                : 1.0;
            return Transform.translate(
              offset: Offset(horizontal, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(opacity: opacity.clamp(0, 1), child: child),
              ),
            );
          },
          child: Text(
            widget.character.emoji,
            key: const Key('quick-mode-character'),
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
