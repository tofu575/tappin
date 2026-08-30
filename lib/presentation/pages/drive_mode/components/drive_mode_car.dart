import 'package:flutter/material.dart';

const _lapDuration = Duration(seconds: 6);

/// Drive mode中、画面下部を穏やかに横切り続ける車を表示する。
class DriveModeCar extends StatefulWidget {
  const DriveModeCar({super.key});

  @override
  State<DriveModeCar> createState() => _DriveModeCarState();
}

class _DriveModeCarState extends State<DriveModeCar>
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
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      key: const Key('drive-mode-car'),
      height: 40,
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
          child: Icon(
            Icons.directions_car_rounded,
            size: 30,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
