import 'package:flutter/material.dart';

import 'package:tappin/presentation/widgets/tap_pin_mark.dart';
import 'package:tappin/presentation/widgets/tap_pin_mark_state.dart';

/// [progress]に合わせてロケーションピンを下から上へ塗りつぶす。
class RecordingPinIndicator extends StatelessWidget {
  const RecordingPinIndicator({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: const Key('recording-pin-indicator'),
      animation: progress,
      builder: (context, _) => SizedBox.square(
        dimension: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TapPinMark(
              key: const Key('recording-pin-fill'),
              state: progress.value >= 1
                  ? TapPinMarkState.success
                  : TapPinMarkState.recording,
              size: 172,
              fillProgress: progress.value,
            ),
          ],
        ),
      ),
    );
  }
}
