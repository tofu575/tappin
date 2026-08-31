import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/services/screen_awake_gateway.dart';
import 'package:tappin/presentation/pages/quick_mode/components/quick_mode_character_lane.dart';
import 'package:tappin/presentation/pages/quick_mode/components/recording_pin_indicator.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_direction.dart';
import 'package:tappin/presentation/providers/recording_provider.dart';
import 'package:tappin/presentation/providers/screen_awake_provider.dart';
import 'package:tappin/presentation/widgets/record_action.dart';
import 'package:tappin/presentation/widgets/record_feedback.dart';
import 'package:tappin/presentation/widgets/record_feedback_controller.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

// GestureDetectorの長押し認識約500msと合わせ、合計約1.5秒にする。
const _exitProgressDuration = Duration(seconds: 1);
const _minimumPinFillDuration = Duration(milliseconds: 250);
const _completedPinHoldDuration = Duration(milliseconds: 100);

/// 画面全体のタップで記録し、約1.5秒の長押しで終了するQuick Mode画面。
class QuickModePage extends ConsumerStatefulWidget {
  const QuickModePage({super.key, required this.character});

  final QuickModeCharacter character;

  @override
  ConsumerState<QuickModePage> createState() => _QuickModePageState();
}

class _QuickModePageState extends ConsumerState<QuickModePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _feedbackController = RecordFeedbackController();
  late final AnimationController _exitProgressController;
  late final AnimationController _pinProgressController;
  late final ScreenAwakeGateway _screenAwakeGateway;
  int _recordCount = 0;
  bool _isHolding = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenAwakeGateway = ref.read(screenAwakeProvider);
    _exitProgressController = AnimationController(
      vsync: this,
      duration: _exitProgressDuration,
    )..addStatusListener(_handleExitProgress);
    _pinProgressController = AnimationController(
      vsync: this,
      duration: _minimumPinFillDuration,
    );
    unawaited(_screenAwakeGateway.enable());
  }

  /// バックグラウンド中は解除し、Quick Modeへ復帰した場合だけ再度有効化する。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_screenAwakeGateway.enable());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_screenAwakeGateway.disable());
    }
  }

  void _handleExitProgress(AnimationStatus status) {
    if (status != AnimationStatus.completed || _isExiting) return;
    _isExiting = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuickModeTransitionPage(
          direction: QuickModeTransitionDirection.exiting,
          character: widget.character,
          onCompleted: (transitionContext) {
            Navigator.of(transitionContext).pop();
          },
        ),
      ),
    );
  }

  Future<void> _record() async {
    final minimumFill = Future<void>.delayed(_minimumPinFillDuration);
    unawaited(
      _pinProgressController.animateTo(
        0.82,
        duration: _minimumPinFillDuration,
        curve: Curves.easeOut,
      ),
    );
    var succeeded = false;
    await performRecordAction(
      context: context,
      ref: ref,
      feedbackController: _feedbackController,
      onSuccess: (_) {
        succeeded = true;
        if (mounted) setState(() => _recordCount++);
      },
    );
    await minimumFill;
    if (!mounted) return;
    if (!succeeded) {
      await _pinProgressController.animateBack(
        0,
        duration: const Duration(milliseconds: 120),
      );
      return;
    }

    await _pinProgressController.animateTo(
      1,
      duration: const Duration(milliseconds: 30),
      curve: Curves.easeOut,
    );
    await Future<void>.delayed(_completedPinHoldDuration);
    if (mounted) _pinProgressController.value = 0;
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
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_screenAwakeGateway.disable());
    _exitProgressController
      ..removeStatusListener(_handleExitProgress)
      ..dispose();
    _pinProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.tapPinColors;
    final textTheme = Theme.of(context).textTheme;
    final isRecording = ref.watch(recordingProvider).isLoading;

    return PopScope(
      canPop: false,
      child: RecordFeedback(
        controller: _feedbackController,
        child: Scaffold(
          backgroundColor: colors.quickModeSurface,
          // TapとLongPressをgesture arenaで競合させ、終了長押しによる記録を防ぐ。
          body: GestureDetector(
            key: const Key('quick-record-area'),
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
                          Icon(Icons.route_rounded, color: colors.quickModeInk),
                          const SizedBox(width: 10),
                          Text(
                            'QUICK MODE',
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.quickModeInk,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      RecordingPinIndicator(progress: _pinProgressController),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          '$_recordCount 件記録済み',
                          key: ValueKey(_recordCount),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
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
                                  color: colors.pinRed,
                                  backgroundColor: colors.paperElevated,
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
                              color: colors.quickModeInk,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '画面のどこでもタップで記録',
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.quickModeInk,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '終了するには約1.5秒長押し',
                              style: textTheme.bodyMedium?.copyWith(
                                color:
                                    colors.quickModeInk.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      QuickModeCharacterLane(character: widget.character),
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
