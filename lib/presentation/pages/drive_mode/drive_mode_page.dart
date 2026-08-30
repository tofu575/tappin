import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/presentation/pages/drive_mode/drive_mode_transition_page.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_transition_direction.dart';
import 'package:tappin/presentation/providers/recording_provider.dart';
import 'package:tappin/presentation/widgets/record_action.dart';
import 'package:tappin/presentation/widgets/record_feedback.dart';
import 'package:tappin/presentation/widgets/record_feedback_controller.dart';

const _exitProgressDuration = Duration(seconds: 1);

/// 画面全体のタップで記録し、約1.5秒の長押しで安全に終了するDrive mode画面。
class DriveModePage extends ConsumerStatefulWidget {
  const DriveModePage({super.key});

  @override
  ConsumerState<DriveModePage> createState() => _DriveModePageState();
}

class _DriveModePageState extends ConsumerState<DriveModePage>
    with SingleTickerProviderStateMixin {
  final _feedbackController = RecordFeedbackController();
  late final AnimationController _exitProgressController;
  int _recordCount = 0;
  bool _isHolding = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _exitProgressController = AnimationController(
      vsync: this,
      duration: _exitProgressDuration,
    )..addStatusListener(_handleExitProgress);
  }

  void _handleExitProgress(AnimationStatus status) {
    if (status != AnimationStatus.completed || _isExiting) return;
    _isExiting = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriveModeTransitionPage(
          direction: DriveTransitionDirection.exiting,
          onCompleted: (transitionContext) {
            Navigator.of(transitionContext).pop();
          },
        ),
      ),
    );
  }

  Future<void> _record() async {
    await performRecordAction(
      context: context,
      ref: ref,
      feedbackController: _feedbackController,
      onSuccess: (_) {
        if (mounted) setState(() => _recordCount++);
      },
    );
  }

  void _startExitHold(LongPressStartDetails _) {
    if (_isExiting) return;
    setState(() => _isHolding = true);
    unawaited(_exitProgressController.forward(from: 0));
  }

  void _cancelExitHold() {
    if (_isExiting || !_isHolding) return;
    setState(() => _isHolding = false);
    _exitProgressController
      ..stop()
      ..value = 0;
  }

  @override
  void dispose() {
    _exitProgressController
      ..removeStatusListener(_handleExitProgress)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRecording = ref.watch(recordingProvider).isLoading;

    return PopScope(
      canPop: false,
      child: RecordFeedback(
        controller: _feedbackController,
        child: Scaffold(
          backgroundColor: colorScheme.primaryContainer,
          // TapとLongPressをgesture arenaで競合させ、終了長押しによる記録を防ぐ。
          body: GestureDetector(
            key: const Key('drive-record-area'),
            behavior: HitTestBehavior.opaque,
            onTap: isRecording || _isExiting ? null : _record,
            onLongPressStart: _startExitHold,
            onLongPressEnd: (_) => _cancelExitHold(),
            onLongPressCancel: _cancelExitHold,
            child: SafeArea(
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'DRIVE MODE',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: isRecording
                            ? CircularProgressIndicator(
                                key: const Key('drive-recording-progress'),
                                color: colorScheme.primary,
                              )
                            : Column(
                                key: ValueKey(_recordCount),
                                children: [
                                  Text(
                                    '$_recordCount',
                                    style: textTheme.displayLarge?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'このドライブで記録済み',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const Spacer(),
                      if (_isHolding)
                        Column(
                          children: [
                            AnimatedBuilder(
                              animation: _exitProgressController,
                              builder: (context, _) => SizedBox(
                                width: 52,
                                height: 52,
                                child: CircularProgressIndicator(
                                  key: const Key('drive-exit-progress'),
                                  value: _exitProgressController.value,
                                  strokeWidth: 5,
                                  color: colorScheme.primary,
                                  backgroundColor: colorScheme.surfaceContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('そのまま長押しで終了'),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 36,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '画面のどこでもタップで記録',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '終了するには約1.5秒長押し',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
