import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:model/model.dart';
import 'package:usecase/usecase.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/providers/recording_provider.dart';
import 'package:tappin/presentation/widgets/record_feedback_controller.dart';

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
    ).showSnackBar(SnackBar(content: Text(context.l10n.recordSuccess)));
  } on LocationPermissionPermanentlyDeniedException {
    if (!context.mounted) return;
    feedbackController.showFailure();
    ref.read(interactorProvider).playRecordFailure();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.permissionRequiredTitle),
        content: Text(context.l10n.permissionRequiredDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(interactorProvider).openLocationSettings();
            },
            child: Text(context.l10n.openSettings),
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
    ).showSnackBar(SnackBar(content: Text(context.l10n.permissionDenied)));
  } catch (error) {
    if (!context.mounted) return;
    feedbackController.showFailure();
    ref.read(interactorProvider).playRecordFailure();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.recordError(error.toString()))),
    );
  }
}
