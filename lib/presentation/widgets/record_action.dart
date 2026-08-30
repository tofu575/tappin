import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/recording_provider.dart';
import 'package:tappin/presentation/widgets/record_feedback_controller.dart';

const _permissionDeniedMessage = '位置情報が許可されませんでした';
const _permissionPermanentlyDeniedTitle = '位置情報の許可が必要です';
const _permissionPermanentlyDeniedBody = '設定から位置情報へのアクセスを許可してください';
const _permissionOpenSettings = '設定を開く';
const _recordSuccessMessage = '現在地を記録しました';
const _recordErrorPrefix = 'エラーが発生しました: ';

/// 共通の記録UseCaseを呼び、[feedbackController]と画面別の[onSuccess]へ成功を通知する。
/// 位置権限・保存失敗は成功扱いにせず、[context]上へ既存のエラー表示を行う。
Future<void> performRecordAction({
  required BuildContext context,
  required WidgetRef ref,
  required RecordFeedbackController feedbackController,
  ValueChanged<Pin>? onSuccess,
}) async {
  try {
    final pin = await ref
        .read(recordingProvider.notifier)
        .recordCurrentLocation();
    if (pin == null || !context.mounted) return;

    onSuccess?.call(pin);
    feedbackController.showSuccess();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(_recordSuccessMessage)));
  } on LocationPermissionPermanentlyDeniedException {
    if (!context.mounted) return;
    feedbackController.showFailure();
    ref.read(interactorProvider).playRecordFailure();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(_permissionPermanentlyDeniedTitle),
        content: const Text(_permissionPermanentlyDeniedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(interactorProvider).openLocationSettings();
            },
            child: const Text(_permissionOpenSettings),
          ),
        ],
      ),
    );
  } on LocationPermissionDeniedException {
    if (!context.mounted) return;
    feedbackController.showFailure();
    ref.read(interactorProvider).playRecordFailure();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(_permissionDeniedMessage)));
  } catch (error) {
    if (!context.mounted) return;
    feedbackController.showFailure();
    ref.read(interactorProvider).playRecordFailure();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$_recordErrorPrefix$error')));
  }
}
