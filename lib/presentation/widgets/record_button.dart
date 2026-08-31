import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/widgets/tap_pin_mark.dart';
import 'package:tappin/presentation/widgets/tap_pin_mark_state.dart';

/// 紙面へ画鋲を留める主操作を十分なHit Areaで表示する。
class RecordButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const RecordButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final colors = context.tapPinColors;

    return GestureDetector(
      onTapDown: widget.isLoading ? null : _handleTapDown,
      onTapUp: widget.isLoading ? null : _handleTapUp,
      onTapCancel: widget.isLoading ? null : _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.paperElevated,
            border: Border.all(color: colors.dividerInk, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: colors.ink.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.isLoading
              ? Center(
                  child: TapPinMark(
                    state: TapPinMarkState.recording,
                    size: 64,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TapPinMark(size: 62),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.record,
                      style: TextStyle(
                        fontSize: 20,
                        color: colors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.pinHere,
                      style: TextStyle(fontSize: 11, color: colors.ink),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
