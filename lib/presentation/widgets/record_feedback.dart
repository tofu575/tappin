import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tappin/presentation/widgets/record_feedback_controller.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

/// [child]全体を覆う記録結果色フラッシュを[controller]から再生するWidget。
class RecordFeedback extends StatefulWidget {
  const RecordFeedback({
    super.key,
    required this.controller,
    required this.child,
  });

  final RecordFeedbackController controller;
  final Widget child;

  @override
  State<RecordFeedback> createState() => _RecordFeedbackState();
}

class _RecordFeedbackState extends State<RecordFeedback>
    with SingleTickerProviderStateMixin {
  static const _feedbackDuration = Duration(milliseconds: 400);

  late final AnimationController _animationController;
  late final Animation<double> _opacity;
  bool _isFailure = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _feedbackDuration,
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.22), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(0.22), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 0.22, end: 0), weight: 65),
    ]).animate(_animationController);
    widget.controller.attach(_showSuccessFlash, _showFailureFlash);
  }

  @override
  void didUpdateWidget(covariant RecordFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach(_showSuccessFlash, _showFailureFlash);
      widget.controller.attach(_showSuccessFlash, _showFailureFlash);
    }
  }

  void _showSuccessFlash() {
    setState(() => _isFailure = false);
    unawaited(_animationController.forward(from: 0.05));
  }

  void _showFailureFlash() {
    setState(() => _isFailure = true);
    unawaited(_animationController.forward(from: 0.05));
  }

  @override
  void dispose() {
    widget.controller.detach(_showSuccessFlash, _showFailureFlash);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: FadeTransition(
            opacity: _opacity,
            child: ColoredBox(
              key: const Key('record-feedback-flash'),
              color: _isFailure
                  ? Theme.of(context).colorScheme.error
                  : context.tapPinColors.pinRed,
            ),
          ),
        ),
      ],
    );
  }
}
