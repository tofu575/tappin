import 'package:flutter/material.dart';

/// [progress]に合わせてロケーションピンを下から上へ塗りつぶす。
class RecordingPinIndicator extends StatelessWidget {
  const RecordingPinIndicator({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      key: const Key('recording-pin-indicator'),
      animation: progress,
      builder: (context, _) => SizedBox.square(
        dimension: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 180,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.55),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: progress.value,
                child: Icon(
                  Icons.location_on,
                  key: const Key('recording-pin-fill'),
                  size: 180,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
