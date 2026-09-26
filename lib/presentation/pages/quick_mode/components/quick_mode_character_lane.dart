import 'package:flutter/material.dart';

import 'package:tappin/presentation/assets/tap_pin_visual_assets.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TapPinVisualAssets.movementCharacter(
                widget.character,
                key: const Key('quick-mode-character'),
                size: 30,
              ),
              if (widget.character == QuickModeCharacter.car) ...[
                const SizedBox(width: 6),
                Text(
                  context.l10n.quickModePassengerLabel,
                  key: const Key('quick-mode-passenger-label'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
